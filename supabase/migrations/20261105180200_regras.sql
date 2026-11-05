-- M1 · 3/4 — Regras do manual no banco.
-- Mudanças de status só acontecem por estas funções. Se a interface tiver um bug,
-- o banco recusa mesmo assim (ADR 0003).

-- Log editorial com cadeia de hash -------------------------------------------------

create function public.registrar_log(p_entidade text, p_ref text, p_acao text, p_motivo text default null)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_anterior text;
  v_em timestamptz := clock_timestamp();
  v_por uuid;
  v_hash text;
  v_numero bigint;
begin
  -- Serializa as escritas para a cadeia não bifurcar.
  perform pg_advisory_xact_lock(hashtext('retorica.log_editorial'));

  select p.id into v_por from public.profiles p where p.id = (select auth.uid());

  select l.hash into v_anterior from public.log_editorial l order by l.numero desc limit 1;
  v_anterior := coalesce(v_anterior, repeat('0', 64));

  v_hash := public.hash_log(v_anterior, p_entidade, p_ref, p_acao, p_motivo, v_por, v_em);

  insert into public.log_editorial (entidade, ref, acao, motivo, por, em, hash_anterior, hash)
  values (p_entidade, p_ref, p_acao, p_motivo, v_por, v_em, v_anterior, v_hash)
  returning numero into v_numero;

  return v_numero;
end;
$$;

create function public.hash_log(
  p_anterior text, p_entidade text, p_ref text, p_acao text, p_motivo text, p_por uuid, p_em timestamptz
)
returns text
language sql
immutable
set search_path = ''
as $$
  select encode(
    sha256(convert_to(concat_ws('|',
      p_anterior, p_entidade, p_ref, p_acao, coalesce(p_motivo, ''), coalesce(p_por::text, ''),
      to_char(p_em at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"')
    ), 'UTF8')),
    'hex'
  )
$$;

-- Devolve o número da primeira linha cuja cadeia não confere, ou null se o log está íntegro.
create function public.verificar_log()
returns bigint
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  r record;
  v_anterior text := repeat('0', 64);
begin
  for r in select * from public.log_editorial order by numero loop
    if r.hash_anterior <> v_anterior
       or r.hash <> public.hash_log(r.hash_anterior, r.entidade, r.ref, r.acao, r.motivo, r.por, r.em) then
      return r.numero;
    end if;
    v_anterior := r.hash;
  end loop;
  return null;
end;
$$;

create function public.log_imutavel()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'O log editorial é só de inserção: % não é permitido.', tg_op
    using errcode = 'insufficient_privilege';
end;
$$;

create trigger log_editorial_sem_update_delete
  before update or delete on public.log_editorial
  for each row execute function public.log_imutavel();
create trigger log_editorial_sem_truncate
  before truncate on public.log_editorial
  for each statement execute function public.log_imutavel();

-- Utilitários -------------------------------------------------------------------

create function public.exigir(p_condicao boolean, p_mensagem text)
returns void
language plpgsql
immutable
set search_path = ''
as $$
begin
  if not coalesce(p_condicao, false) then
    raise exception '%', p_mensagem using errcode = 'check_violation';
  end if;
end;
$$;

-- Liga, só nesta transação, a permissão para mudar status.
create function public.abrir_transicao()
returns void
language sql
set search_path = ''
as $$
  select set_config('retorica.transicao', 'on', true);
$$;

create function public.fechar_transicao()
returns void
language sql
set search_path = ''
as $$
  select set_config('retorica.transicao', 'off', true);
$$;

create function public.transicao_aberta()
returns boolean
language sql
stable
set search_path = ''
as $$
  select coalesce(current_setting('retorica.transicao', true), '') = 'on';
$$;

create function public.somar_dias_uteis(p_inicio timestamptz, p_dias integer)
returns timestamptz
language plpgsql
immutable
set search_path = ''
as $$
declare
  v timestamptz := p_inicio;
  n integer := 0;
begin
  -- Considera só sábados e domingos. Feriados ficam a cargo do advogado (documentado na tela A09).
  while n < p_dias loop
    v := v + interval '1 day';
    if extract(isodow from v at time zone 'America/Sao_Paulo') < 6 then
      n := n + 1;
    end if;
  end loop;
  return v;
end;
$$;

-- Matérias: versão, guarda de status e trilha -----------------------------------

create function public.materias_antes()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_conteudo_mudou boolean;
begin
  if tg_op = 'INSERT' then
    if not public.transicao_aberta() then
      perform public.exigir(new.status in ('com_angulo', 'formatada', 'rascunho'),
        'Uma matéria nasce em com_angulo, formatada ou rascunho.');
      new.versao := 1;
      new.publicada_em := null;
    end if;
    return new;
  end if;

  -- Status só muda pelas funções de transição.
  if new.status is distinct from old.status and not public.transicao_aberta() then
    raise exception 'Status da matéria só muda pelas funções de transição (de % para %).', old.status, new.status
      using errcode = 'insufficient_privilege';
  end if;

  v_conteudo_mudou := (
    new.manchete, new.subtitulo, new.mov_realidade, new.mov_contradicao, new.mov_extrapolacao,
    new.mov_escalada, new.mov_arremate, new.corpo, new.formato, new.tecnica, new.tecnica_complementar,
    new.territorio, new.categoria, new.alvo_descricao, new.alvo_identificavel, new.pessoa_identificavel,
    new.imagem_ia, new.slug
  ) is distinct from (
    old.manchete, old.subtitulo, old.mov_realidade, old.mov_contradicao, old.mov_extrapolacao,
    old.mov_escalada, old.mov_arremate, old.corpo, old.formato, old.tecnica, old.tecnica_complementar,
    old.territorio, old.categoria, old.alvo_descricao, old.alvo_identificavel, old.pessoa_identificavel,
    old.imagem_ia, old.slug
  );

  if v_conteudo_mudou then
    if old.status in ('publicada', 'avaliada', 'retirada', 'descartada', 'arquivada')
       and not public.transicao_aberta() then
      raise exception 'Matéria % está encerrada (%). Mudanças passam pelo fluxo de correção.', old.id, old.status
        using errcode = 'check_violation';
    end if;
    new.versao := old.versao + 1;
    -- Verificações e aprovações valem para uma versão: editou, volta para rascunho.
    if old.status in ('em_revisao', 'aprovada') then
      new.status := 'rascunho';
    end if;
  else
    new.versao := old.versao;
  end if;

  return new;
end;
$$;

create function public.materias_depois()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' or new.versao <> old.versao then
    insert into public.materia_versoes (materia_id, numero, conteudo, autor_id)
    values (
      new.id, new.versao,
      to_jsonb(new) - array['status', 'versao', 'publicada_em', 'criado_em', 'atualizado_em'],
      (select p.id from public.profiles p where p.id = (select auth.uid()))
    );
  end if;

  if tg_op = 'INSERT' then
    perform public.registrar_log('materia', new.id::text, 'criada', null);
    if new.pauta_id is not null then
      update public.pautas set status = 'em_producao'
      where id = new.pauta_id and status = 'verificada';
    end if;
  elsif old.status in ('em_revisao', 'aprovada') and new.status = 'rascunho' and new.versao > old.versao then
    perform public.registrar_log('materia', new.id::text, 'voltou_para_rascunho',
      format('Conteúdo editado na versão %s; verificações da versão %s deixam de valer.', new.versao, old.versao));
  end if;

  return null;
end;
$$;

create trigger materias_a_antes
  before insert or update on public.materias
  for each row execute function public.materias_antes();
create trigger materias_b_depois
  after insert or update on public.materias
  for each row execute function public.materias_depois();

-- Pautas: guarda de status ---------------------------------------------------------

create function public.pautas_antes()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    perform public.exigir(new.status = 'garimpo' or public.transicao_aberta(), 'Uma pauta nasce em garimpo.');
    if new.classificacao = 'quente' and new.prazo is null then
      new.prazo := now() + interval '48 hours';
    end if;
    return new;
  end if;
  -- em_producao é marcado pelo gatilho de matérias (security definer, dono da tabela).
  if new.status is distinct from old.status
     and not public.transicao_aberta()
     and not (old.status = 'verificada' and new.status = 'em_producao') then
    raise exception 'Status da pauta só muda pelas funções de transição.' using errcode = 'insufficient_privilege';
  end if;
  return new;
end;
$$;

create trigger pautas_a_antes
  before insert or update on public.pautas
  for each row execute function public.pautas_antes();

create function public.pautas_depois()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.registrar_log('pauta', new.id::text, 'criada', null);
  return null;
end;
$$;

create trigger pautas_b_depois
  after insert on public.pautas
  for each row execute function public.pautas_depois();

-- Pautas: transições (passo 2) ------------------------------------------------------

-- Arquivamento triplo completo para uma fonte.
create function public.fonte_arquivada(p_fonte_id bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.arquivos_fonte a
    where a.fonte_id = p_fonte_id
      and a.captura_sha256 is not null
      and a.backup_ok
      and a.wayback_url is not null
  )
$$;

create function public.verificar_pauta(p_pauta_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.pautas;
begin
  perform public.exigir(public.eh_redacao(), 'Só a redação verifica pautas.');
  select * into v from public.pautas where id = p_pauta_id for update;
  perform public.exigir(found, 'Pauta não encontrada.');
  perform public.exigir(v.status = 'garimpo', format('Pauta está em %s, não em garimpo.', v.status));
  perform public.exigir(
    exists (
      select 1 from public.fontes f
      where f.pauta_id = p_pauta_id and f.confirmada_por_independente and public.fonte_arquivada(f.id)
    ),
    'Checkpoint não pulável: é preciso ao menos uma fonte confirmada por fonte independente, com arquivamento triplo completo (captura, backup e Wayback).'
  );
  perform public.abrir_transicao();
  update public.pautas set status = 'verificada' where id = p_pauta_id;
  perform public.fechar_transicao();
  perform public.registrar_log('pauta', p_pauta_id::text, 'verificada', null);
end;
$$;

create function public.encerrar_pauta(p_pauta_id bigint, p_status public.status_pauta, p_motivo text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.pautas;
begin
  perform public.exigir(public.eh_redacao(), 'Só a redação encerra pautas.');
  perform public.exigir(p_status in ('descartada', 'arquivada'), 'Encerrar é descartar ou arquivar.');
  perform public.exigir(length(trim(coalesce(p_motivo, ''))) > 0, 'Motivo obrigatório: o log prova que há critério.');
  select * into v from public.pautas where id = p_pauta_id for update;
  perform public.exigir(found, 'Pauta não encontrada.');
  perform public.exigir(v.status in ('garimpo', 'verificada'), format('Pauta está em %s.', v.status));
  perform public.abrir_transicao();
  update public.pautas set status = p_status, motivo_encerramento = p_motivo where id = p_pauta_id;
  perform public.fechar_transicao();
  perform public.registrar_log('pauta', p_pauta_id::text, p_status::text, p_motivo);
end;
$$;

-- Matérias: controle editorial (passos 3–7) -------------------------------------

create function public.marcar_etapa(p_materia_id bigint, p_status public.status_materia)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.materias;
begin
  perform public.exigir(public.eh_redacao(), 'Só a redação muda a etapa.');
  perform public.exigir(p_status in ('com_angulo', 'formatada', 'rascunho'), 'Etapas livres: com_angulo, formatada, rascunho.');
  select * into v from public.materias where id = p_materia_id for update;
  perform public.exigir(found, 'Matéria não encontrada.');
  perform public.exigir(v.status in ('com_angulo', 'formatada', 'rascunho'), format('Matéria está em %s.', v.status));
  perform public.abrir_transicao();
  update public.materias set status = p_status where id = p_materia_id;
  perform public.fechar_transicao();
  perform public.registrar_log('materia', p_materia_id::text, 'etapa_' || p_status::text, null);
end;
$$;

-- Revisor externo obrigatório (Addendum v1.1, extra 1, e matriz de risco).
create function public.exige_revisor(p_materia_id bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    (m.categoria = 'A' and m.alvo_identificavel)
    or (m.categoria = 'C' and m.pessoa_identificavel)
    or coalesce((
      select r.aparencia_fisica from public.matriz_risco r
      where r.materia_id = m.id and r.versao = m.versao
    ), false)
  from public.materias m
  where m.id = p_materia_id
$$;

create function public.enviar_para_revisao(p_materia_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.materias;
begin
  perform public.exigir(public.eh_redacao(), 'Só a redação envia para controle editorial.');
  select * into v from public.materias where id = p_materia_id for update;
  perform public.exigir(found, 'Matéria não encontrada.');
  perform public.exigir(v.status in ('com_angulo', 'formatada', 'rascunho'), format('Matéria está em %s.', v.status));
  perform public.exigir(
    length(trim(coalesce(v.mov_realidade, ''))) > 0
    and length(trim(coalesce(v.mov_contradicao, ''))) > 0
    and length(trim(coalesce(v.mov_extrapolacao, ''))) > 0
    and length(trim(coalesce(v.mov_escalada, ''))) > 0
    and length(trim(coalesce(v.mov_arremate, ''))) > 0,
    'Os cinco movimentos precisam estar preenchidos.'
  );
  perform public.exigir(v.tecnica is not null, 'Técnica predominante obrigatória.');
  perform public.exigir(length(trim(coalesce(v.alvo_descricao, ''))) > 0, 'Regra 2: a piada precisa ter um alvo.');
  perform public.abrir_transicao();
  update public.materias set status = 'em_revisao' where id = p_materia_id;
  perform public.fechar_transicao();
  perform public.registrar_log('materia', p_materia_id::text, 'enviada_para_revisao', format('versão %s', v.versao));
end;
$$;

-- O que ainda impede a aprovação. Lista vazia = pode aprovar. Usada pela tela A06.
create function public.pendencias_aprovacao(p_materia_id bigint)
returns text[]
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v public.materias;
  r public.matriz_risco;
  p text[] := '{}';
  t public.tipo_verificacao;
begin
  if not (public.eh_redacao() or public.transicao_aberta()) then
    raise exception 'Só a redação consulta pendências.' using errcode = 'insufficient_privilege';
  end if;
  select * into v from public.materias where id = p_materia_id;
  if not found then
    return array['Matéria não encontrada.'];
  end if;

  if v.status <> 'em_revisao' then
    p := p || format('Matéria está em %s, não em revisão.', v.status);
  end if;

  foreach t in array enum_range(null::public.tipo_verificacao) loop
    if not exists (
      select 1 from public.verificacoes x
      where x.materia_id = v.id and x.versao = v.versao and x.tipo = t and x.ok
    ) then
      p := p || format('Verificação %s ausente ou reprovada na versão %s.', t, v.versao);
    end if;
  end loop;

  select * into r from public.matriz_risco where materia_id = v.id and versao = v.versao;
  if not found then
    p := p || format('Matriz de risco não preenchida na versão %s.', v.versao);
  else
    if r.menores_ou_familiares then
      p := p || 'Matriz: menores ou familiares. Retirar o trecho, sem exceção.'::text;
    end if;
    if r.vitimas_identificaveis then
      p := p || 'Matriz: vítimas identificáveis. Reapontar para o agente ou não publicar.'::text;
    end if;
  end if;

  if public.exige_revisor(v.id) then
    if exists (
      select 1 from public.assinaturas_revisor s
      where s.materia_id = v.id and s.versao = v.versao and s.decisao = 'devolver'
    ) then
      p := p || 'O revisor externo devolveu esta versão.'::text;
    elsif not exists (
      select 1 from public.assinaturas_revisor s
      join public.profiles pr on pr.id = s.revisor_id
      where s.materia_id = v.id and s.versao = v.versao and s.decisao = 'aprovar'
        and pr.papel = 'revisor_externo' and s.revisor_id <> v.autor_id
    ) then
      p := p || format('Revisor externo obrigatório: falta assinatura na versão %s.', v.versao);
    end if;
  end if;

  if v.categoria = 'A' then
    if not exists (
      select 1 from public.pautas pa
      where pa.id = v.pauta_id and pa.status in ('verificada', 'em_producao')
    ) then
      p := p || 'Categoria A: a pauta de origem precisa estar verificada.'::text;
    end if;
    if not exists (
      select 1 from public.fontes f
      where f.pauta_id = v.pauta_id and f.confirmada_por_independente and public.fonte_arquivada(f.id)
    ) then
      p := p || 'Categoria A: falta fonte confirmada com arquivamento triplo.'::text;
    end if;
  end if;

  return p;
end;
$$;

create function public.aprovar_materia(p_materia_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.materias;
  v_pendencias text[];
begin
  perform public.exigir(public.eh_admin(), 'Só o admin (direção editorial) aprova.');
  select * into v from public.materias where id = p_materia_id for update;
  perform public.exigir(found, 'Matéria não encontrada.');
  v_pendencias := public.pendencias_aprovacao(p_materia_id);
  if cardinality(v_pendencias) > 0 then
    raise exception 'Aprovação bloqueada: %', array_to_string(v_pendencias, ' | ') using errcode = 'check_violation';
  end if;
  insert into public.aprovacoes (materia_id, versao, admin_id) values (v.id, v.versao, (select auth.uid()));
  perform public.abrir_transicao();
  update public.materias set status = 'aprovada' where id = p_materia_id;
  perform public.fechar_transicao();
  perform public.registrar_log('materia', p_materia_id::text, 'aprovada', format('versão %s', v.versao));
end;
$$;

create function public.devolver_materia(p_materia_id bigint, p_motivo text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.materias;
begin
  perform public.exigir(public.eh_admin(), 'Só o admin devolve para reescrita.');
  perform public.exigir(length(trim(coalesce(p_motivo, ''))) > 0, 'Motivo obrigatório.');
  select * into v from public.materias where id = p_materia_id for update;
  perform public.exigir(found, 'Matéria não encontrada.');
  perform public.exigir(v.status in ('em_revisao', 'aprovada'), format('Matéria está em %s.', v.status));
  perform public.abrir_transicao();
  update public.materias set status = 'rascunho' where id = p_materia_id;
  perform public.fechar_transicao();
  perform public.registrar_log('materia', p_materia_id::text, 'devolvida', p_motivo);
end;
$$;

create function public.descartar_materia(p_materia_id bigint, p_motivo text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.materias;
begin
  perform public.exigir(public.eh_admin(), 'Só o admin descarta matérias.');
  perform public.exigir(length(trim(coalesce(p_motivo, ''))) > 0, 'Motivo obrigatório: recusas são a prova de critério.');
  select * into v from public.materias where id = p_materia_id for update;
  perform public.exigir(found, 'Matéria não encontrada.');
  perform public.exigir(v.status not in ('publicada', 'avaliada', 'retirada', 'descartada'),
    format('Matéria está em %s. Publicadas saem pelo kill switch.', v.status));
  perform public.abrir_transicao();
  update public.materias set status = 'descartada' where id = p_materia_id;
  perform public.fechar_transicao();
  perform public.registrar_log('materia', p_materia_id::text, 'descartada', p_motivo);
end;
$$;

create function public.publicar_materia(p_materia_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.materias;
begin
  perform public.exigir(public.eh_admin(), 'Só o admin publica.');
  select * into v from public.materias where id = p_materia_id for update;
  perform public.exigir(found, 'Matéria não encontrada.');
  perform public.exigir(v.status = 'aprovada', format('Matéria está em %s, não aprovada.', v.status));
  perform public.exigir(
    exists (select 1 from public.aprovacoes a where a.materia_id = v.id and a.versao = v.versao),
    format('Não há aprovação para a versão %s.', v.versao)
  );
  perform public.abrir_transicao();
  update public.materias set status = 'publicada', publicada_em = coalesce(publicada_em, now()) where id = p_materia_id;
  perform public.fechar_transicao();
  perform public.registrar_log('materia', p_materia_id::text, 'publicada', format('versão %s', v.versao));
end;
$$;

-- Usada pelo kill switch nível 3 e por decisão jurídica de suspender.
create function public.retirar_materia(p_materia_id bigint, p_motivo text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.materias;
begin
  perform public.exigir(public.eh_admin(), 'Só o admin retira matérias do ar.');
  perform public.exigir(length(trim(coalesce(p_motivo, ''))) > 0, 'Motivo obrigatório.');
  select * into v from public.materias where id = p_materia_id for update;
  perform public.exigir(found, 'Matéria não encontrada.');
  perform public.exigir(v.status in ('publicada', 'avaliada', 'aprovada'), format('Matéria está em %s.', v.status));
  perform public.abrir_transicao();
  update public.materias set status = 'retirada' where id = p_materia_id;
  perform public.fechar_transicao();
  perform public.registrar_log('materia', p_materia_id::text, 'retirada', p_motivo);
end;
$$;

-- Revisor externo ----------------------------------------------------------------

create function public.atribuir_revisor(p_materia_id bigint, p_revisor_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.materias;
begin
  perform public.exigir(public.eh_admin(), 'Só o admin atribui revisores.');
  select * into v from public.materias where id = p_materia_id;
  perform public.exigir(found, 'Matéria não encontrada.');
  perform public.exigir(
    exists (select 1 from public.profiles p where p.id = p_revisor_id and p.papel = 'revisor_externo' and p.ativo),
    'A pessoa precisa ter o papel revisor_externo e estar ativa.'
  );
  perform public.exigir(p_revisor_id <> v.autor_id, 'Revisor externo = pessoa que não escreveu a peça.');
  insert into public.revisores_atribuidos (materia_id, revisor_id, atribuido_por)
  values (p_materia_id, p_revisor_id, (select auth.uid()))
  on conflict do nothing;
  perform public.registrar_log('materia', p_materia_id::text, 'revisor_atribuido', null);
end;
$$;

create function public.assinar_revisao(p_materia_id bigint, p_decisao public.decisao_revisor, p_comentario text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.materias;
  v_uid uuid := (select auth.uid());
begin
  perform public.exigir(public.eh_revisor(), 'Só o revisor externo assina a revisão externa.');
  select * into v from public.materias where id = p_materia_id;
  perform public.exigir(found, 'Matéria não encontrada.');
  perform public.exigir(
    exists (select 1 from public.revisores_atribuidos r where r.materia_id = v.id and r.revisor_id = v_uid),
    'Esta matéria não foi atribuída a você.'
  );
  perform public.exigir(v.autor_id <> v_uid, 'Quem escreveu não revisa.');
  perform public.exigir(v.status = 'em_revisao', format('Matéria está em %s, não em revisão.', v.status));
  perform public.exigir(p_decisao = 'aprovar' or length(trim(coalesce(p_comentario, ''))) > 0,
    'Ao devolver, explique o motivo.');
  insert into public.assinaturas_revisor (materia_id, versao, revisor_id, decisao, comentario)
  values (v.id, v.versao, v_uid, p_decisao, p_comentario);
  perform public.registrar_log('materia', p_materia_id::text, 'revisao_externa_' || p_decisao::text,
    format('versão %s', v.versao));
end;
$$;

-- Kill switch (Addendum v1.1, Entrega 2, item 5) --------------------------------

create function public.abrir_ocorrencia(p_materia_id bigint, p_nivel smallint, p_descricao text)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id bigint;
begin
  perform public.exigir(public.eh_redacao(), 'Só a redação registra ocorrências.');
  perform public.exigir(p_nivel between 1 and 3, 'Nível entre 1 e 3.');
  perform public.exigir(p_nivel < 3 or public.eh_admin(), 'Nível 3 (suspensão) é só do admin.');
  perform public.exigir(length(trim(coalesce(p_descricao, ''))) > 0, 'Descreva o fenômeno.');
  insert into public.ocorrencias (materia_id, nivel, descricao, monitorar_ate, aberta_por)
  values (
    p_materia_id, p_nivel, p_descricao,
    case when p_nivel = 2 then now() + interval '48 hours' end,
    (select auth.uid())
  )
  returning id into v_id;
  perform public.registrar_log('ocorrencia', v_id::text, 'aberta_nivel_' || p_nivel, p_descricao);
  if p_nivel = 3 then
    perform public.suspender_por_ocorrencia(p_materia_id, v_id);
  end if;
  return v_id;
end;
$$;

create function public.elevar_ocorrencia(p_ocorrencia_id bigint, p_nivel smallint, p_motivo text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.ocorrencias;
begin
  perform public.exigir(public.eh_redacao(), 'Só a redação altera ocorrências.');
  select * into o from public.ocorrencias where id = p_ocorrencia_id for update;
  perform public.exigir(found and o.aberta, 'Ocorrência não encontrada ou encerrada.');
  perform public.exigir(p_nivel > o.nivel and p_nivel <= 3, 'Só é possível subir de nível.');
  perform public.exigir(p_nivel < 3 or public.eh_admin(), 'Nível 3 (suspensão) é só do admin.');
  update public.ocorrencias
  set nivel = p_nivel,
      monitorar_ate = case when p_nivel = 2 then now() + interval '48 hours' else monitorar_ate end
  where id = p_ocorrencia_id;
  perform public.registrar_log('ocorrencia', p_ocorrencia_id::text, 'elevada_nivel_' || p_nivel, p_motivo);
  if p_nivel = 3 then
    perform public.suspender_por_ocorrencia(o.materia_id, p_ocorrencia_id);
  end if;
end;
$$;

create function public.suspender_por_ocorrencia(p_materia_id bigint, p_ocorrencia_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if exists (select 1 from public.materias m where m.id = p_materia_id and m.status in ('publicada', 'avaliada', 'aprovada')) then
    perform public.retirar_materia(p_materia_id, case
      when p_ocorrencia_id is null then 'Suspensão por decisão jurídica.'
      else format('Kill switch nível 3 (ocorrência %s).', p_ocorrencia_id)
    end);
  end if;
end;
$$;

create function public.encerrar_ocorrencia(p_ocorrencia_id bigint, p_acao text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.ocorrencias;
begin
  perform public.exigir(public.eh_redacao(), 'Só a redação encerra ocorrências.');
  perform public.exigir(length(trim(coalesce(p_acao, ''))) > 0, 'Registre a ação tomada.');
  select * into o from public.ocorrencias where id = p_ocorrencia_id for update;
  perform public.exigir(found and o.aberta, 'Ocorrência não encontrada ou já encerrada.');
  perform public.exigir(o.nivel < 3 or public.eh_admin(), 'Ocorrência nível 3 é encerrada pelo admin.');
  update public.ocorrencias set aberta = false, acao = p_acao, encerrada_em = now() where id = p_ocorrencia_id;
  perform public.registrar_log('ocorrencia', p_ocorrencia_id::text, 'encerrada', p_acao);
end;
$$;

-- Notificações jurídicas (Addendum v1.1, Entrega 2, item 3) ---------------------

create function public.registrar_notificacao(p_materia_id bigint, p_origem text, p_nivel smallint, p_recebida_em timestamptz default now())
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id bigint;
begin
  perform public.exigir(public.eh_admin(), 'Notificações jurídicas são só do admin.');
  perform public.exigir(p_nivel between 1 and 3, 'Nível entre 1 e 3.');
  insert into public.notificacoes_juridicas (materia_id, origem, nivel, recebida_em, prazo_em, registrada_por)
  values (
    p_materia_id, p_origem, p_nivel, p_recebida_em,
    case p_nivel
      when 1 then p_recebida_em + interval '24 hours'
      when 2 then p_recebida_em + interval '72 hours'
      else public.somar_dias_uteis(p_recebida_em, 7)
    end,
    (select auth.uid())
  )
  returning id into v_id;
  perform public.registrar_log('juridico', v_id::text, 'registrada_nivel_' || p_nivel, p_origem);
  return v_id;
end;
$$;

create function public.decidir_notificacao(p_notificacao_id bigint, p_decisao text, p_parecer text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  n public.notificacoes_juridicas;
begin
  perform public.exigir(public.eh_admin(), 'Notificações jurídicas são só do admin.');
  perform public.exigir(p_decisao in ('sustentar', 'retratar', 'esclarecer', 'suspender'), 'Decisão inválida.');
  select * into n from public.notificacoes_juridicas where id = p_notificacao_id for update;
  perform public.exigir(found, 'Notificação não encontrada.');
  update public.notificacoes_juridicas
  set decisao = p_decisao, parecer = p_parecer, decidida_em = now()
  where id = p_notificacao_id;
  perform public.registrar_log('juridico', p_notificacao_id::text, 'decisao_' || p_decisao, p_parecer);
  if p_decisao = 'suspender' and n.materia_id is not null then
    perform public.suspender_por_ocorrencia(n.materia_id, null);
  end if;
end;
$$;
