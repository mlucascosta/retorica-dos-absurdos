-- M1 · 4/4 — Privilégios e RLS.
-- Ponto de partida: ninguém pode nada. Cada permissão abaixo é explícita.
-- O site não usa service_role (ADR 0003): estas regras valem para tudo que vem do app.

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke execute on all functions in schema public from public, anon, authenticated;
alter default privileges in schema public revoke all on tables from anon, authenticated;
alter default privileges in schema public revoke all on sequences from anon, authenticated;
alter default privileges in schema public revoke execute on functions from public, anon, authenticated;

grant usage on schema public to anon, authenticated;

-- RLS em todas as tabelas --------------------------------------------------------
alter table public.territorios enable row level security;
alter table public.formatos enable row level security;
alter table public.tecnicas enable row level security;
alter table public.profiles enable row level security;
alter table public.pautas enable row level security;
alter table public.fontes enable row level security;
alter table public.arquivos_fonte enable row level security;
alter table public.materias enable row level security;
alter table public.materia_versoes enable row level security;
alter table public.verificacoes enable row level security;
alter table public.matriz_risco enable row level security;
alter table public.revisores_atribuidos enable row level security;
alter table public.assinaturas_revisor enable row level security;
alter table public.aprovacoes enable row level security;
alter table public.correcoes enable row level security;
alter table public.registro_alvos enable row level security;
alter table public.ocorrencias enable row level security;
alter table public.notificacoes_juridicas enable row level security;
alter table public.log_editorial enable row level security;

-- Auxiliares chamadas pelos gatilhos, que rodam com o papel de quem escreve.
-- abrir_transicao() NÃO entra aqui: só as funções de transição (security definer) a chamam.
grant execute on function public.exigir(boolean, text), public.transicao_aberta() to authenticated;

-- Funções que o app chama -------------------------------------------------------
grant execute on function
  public.papel_atual(), public.eh_admin(), public.eh_redacao(), public.eh_revisor(),
  public.exige_revisor(bigint), public.pendencias_aprovacao(bigint), public.verificar_log(),
  public.verificar_pauta(bigint), public.encerrar_pauta(bigint, public.status_pauta, text),
  public.marcar_etapa(bigint, public.status_materia), public.enviar_para_revisao(bigint),
  public.aprovar_materia(bigint), public.devolver_materia(bigint, text), public.descartar_materia(bigint, text),
  public.publicar_materia(bigint), public.retirar_materia(bigint, text),
  public.atribuir_revisor(bigint, uuid), public.assinar_revisao(bigint, public.decisao_revisor, text),
  public.abrir_ocorrencia(bigint, smallint, text), public.elevar_ocorrencia(bigint, smallint, text),
  public.encerrar_ocorrencia(bigint, text),
  public.registrar_notificacao(bigint, text, smallint, timestamptz), public.decidir_notificacao(bigint, text, text)
to authenticated;

-- Taxonomias: leitura pública, escrita do admin -------------------------------
grant select on public.territorios, public.formatos, public.tecnicas to anon, authenticated;
grant insert, update on public.territorios, public.formatos, public.tecnicas to authenticated;

create policy "taxonomia: leitura pública" on public.territorios for select to anon, authenticated using (true);
create policy "taxonomia: admin escreve" on public.territorios for insert to authenticated with check ((select public.eh_admin()));
create policy "taxonomia: admin altera" on public.territorios for update to authenticated using ((select public.eh_admin()));
create policy "taxonomia: leitura pública" on public.formatos for select to anon, authenticated using (true);
create policy "taxonomia: admin escreve" on public.formatos for insert to authenticated with check ((select public.eh_admin()));
create policy "taxonomia: admin altera" on public.formatos for update to authenticated using ((select public.eh_admin()));
create policy "taxonomia: leitura pública" on public.tecnicas for select to anon, authenticated using (true);
create policy "taxonomia: admin escreve" on public.tecnicas for insert to authenticated with check ((select public.eh_admin()));
create policy "taxonomia: admin altera" on public.tecnicas for update to authenticated using ((select public.eh_admin()));

-- Perfis --------------------------------------------------------------------------
grant select on public.profiles to authenticated;
grant update (nome, papel, ativo) on public.profiles to authenticated;

create policy "perfil: cada um vê o seu, a redação vê todos" on public.profiles for select to authenticated
  using (id = (select auth.uid()) or (select public.eh_redacao()));
create policy "perfil: só o admin altera" on public.profiles for update to authenticated
  using ((select public.eh_admin())) with check ((select public.eh_admin()));

-- Pautas, fontes e arquivos: redação --------------------------------------------
grant select on public.pautas to authenticated;
grant insert (titulo, territorio, classificacao, responsavel, prazo) on public.pautas to authenticated;
grant update (titulo, territorio, classificacao, responsavel, prazo) on public.pautas to authenticated;
create policy "pauta: redação lê" on public.pautas for select to authenticated using ((select public.eh_redacao()));
create policy "pauta: redação cria" on public.pautas for insert to authenticated with check ((select public.eh_redacao()));
create policy "pauta: redação edita" on public.pautas for update to authenticated
  using ((select public.eh_redacao())) with check ((select public.eh_redacao()));

grant select, delete on public.fontes to authenticated;
grant insert (pauta_id, url, nome, tipo, coletado_em, trecho, confirmada_por_independente) on public.fontes to authenticated;
grant update (url, nome, tipo, coletado_em, trecho, confirmada_por_independente) on public.fontes to authenticated;
create policy "fonte: redação lê" on public.fontes for select to authenticated using ((select public.eh_redacao()));
create policy "fonte: redação cria" on public.fontes for insert to authenticated with check ((select public.eh_redacao()));
create policy "fonte: redação edita" on public.fontes for update to authenticated
  using ((select public.eh_redacao())) with check ((select public.eh_redacao()));
create policy "fonte: redação apaga só em garimpo" on public.fontes for delete to authenticated
  using ((select public.eh_redacao()) and exists (
    select 1 from public.pautas p where p.id = pauta_id and p.status = 'garimpo'
  ));

grant select on public.arquivos_fonte to authenticated;
grant insert (fonte_id, captura_path, captura_sha256, backup_ok, wayback_url) on public.arquivos_fonte to authenticated;
grant update (captura_path, captura_sha256, backup_ok, wayback_url) on public.arquivos_fonte to authenticated;
create policy "arquivo: redação lê" on public.arquivos_fonte for select to authenticated using ((select public.eh_redacao()));
create policy "arquivo: redação cria" on public.arquivos_fonte for insert to authenticated with check ((select public.eh_redacao()));
create policy "arquivo: redação edita" on public.arquivos_fonte for update to authenticated
  using ((select public.eh_redacao())) with check ((select public.eh_redacao()));

-- Matérias ------------------------------------------------------------------------
-- Leitor anônimo: só matérias publicadas e só as colunas que vão para o site.
grant select (id, slug, manchete, subtitulo, corpo, formato, tecnica, territorio, categoria,
              imagem_ia, anuncios_ativos, status, versao, publicada_em)
  on public.materias to anon;
grant select on public.materias to authenticated;
grant insert (pauta_id, slug, manchete, subtitulo, mov_realidade, mov_contradicao, mov_extrapolacao,
              mov_escalada, mov_arremate, corpo, formato, tecnica, tecnica_complementar, territorio,
              categoria, alvo_descricao, alvo_identificavel, pessoa_identificavel, imagem_ia,
              anuncios_ativos, motivo_sem_ads, status, autor_id)
  on public.materias to authenticated;
grant update (slug, manchete, subtitulo, mov_realidade, mov_contradicao, mov_extrapolacao,
              mov_escalada, mov_arremate, corpo, formato, tecnica, tecnica_complementar, territorio,
              categoria, alvo_descricao, alvo_identificavel, pessoa_identificavel, imagem_ia,
              anuncios_ativos, motivo_sem_ads)
  on public.materias to authenticated;

create policy "matéria: público lê publicadas" on public.materias for select to anon
  using (status = 'publicada');
create policy "matéria: redação lê todas" on public.materias for select to authenticated
  using ((select public.eh_redacao()));
create policy "matéria: revisor lê as atribuídas" on public.materias for select to authenticated
  using ((select public.eh_revisor()) and exists (
    select 1 from public.revisores_atribuidos r where r.materia_id = materias.id and r.revisor_id = (select auth.uid())
  ));
create policy "matéria: redação cria em nome próprio" on public.materias for insert to authenticated
  with check ((select public.eh_redacao()) and autor_id = (select auth.uid()));
create policy "matéria: redação edita" on public.materias for update to authenticated
  using ((select public.eh_redacao())) with check ((select public.eh_redacao()));

grant select on public.materia_versoes to authenticated;
create policy "versão: redação lê" on public.materia_versoes for select to authenticated
  using ((select public.eh_redacao()));
create policy "versão: revisor lê as atribuídas" on public.materia_versoes for select to authenticated
  using ((select public.eh_revisor()) and exists (
    select 1 from public.revisores_atribuidos r where r.materia_id = materia_versoes.materia_id and r.revisor_id = (select auth.uid())
  ));

-- Controle editorial --------------------------------------------------------------
-- Verificações e matriz: só para a versão atual de uma matéria em rascunho ou revisão.
grant select on public.verificacoes, public.matriz_risco to authenticated;
grant insert (materia_id, versao, tipo, itens, ok, por) on public.verificacoes to authenticated;
grant update (itens, ok, por, em) on public.verificacoes to authenticated;
grant insert (materia_id, versao, aparencia_fisica, menores_ou_familiares, vitimas_identificaveis, pessoa_privada, instituicao_real, por)
  on public.matriz_risco to authenticated;
grant update (aparencia_fisica, menores_ou_familiares, vitimas_identificaveis, pessoa_privada, instituicao_real, por, em)
  on public.matriz_risco to authenticated;

create policy "verificação: redação lê" on public.verificacoes for select to authenticated
  using ((select public.eh_redacao()));
create policy "verificação: revisor lê as atribuídas" on public.verificacoes for select to authenticated
  using ((select public.eh_revisor()) and exists (
    select 1 from public.revisores_atribuidos r where r.materia_id = verificacoes.materia_id and r.revisor_id = (select auth.uid())
  ));
create policy "verificação: redação registra na versão atual" on public.verificacoes for insert to authenticated
  with check ((select public.eh_redacao()) and por = (select auth.uid()) and exists (
    select 1 from public.materias m
    where m.id = materia_id and m.versao = verificacoes.versao and m.status in ('rascunho', 'em_revisao')
  ));
create policy "verificação: redação corrige na versão atual" on public.verificacoes for update to authenticated
  using ((select public.eh_redacao()))
  with check ((select public.eh_redacao()) and por = (select auth.uid()) and exists (
    select 1 from public.materias m
    where m.id = materia_id and m.versao = verificacoes.versao and m.status in ('rascunho', 'em_revisao')
  ));

create policy "matriz: redação lê" on public.matriz_risco for select to authenticated
  using ((select public.eh_redacao()));
create policy "matriz: revisor lê as atribuídas" on public.matriz_risco for select to authenticated
  using ((select public.eh_revisor()) and exists (
    select 1 from public.revisores_atribuidos r where r.materia_id = matriz_risco.materia_id and r.revisor_id = (select auth.uid())
  ));
create policy "matriz: redação registra na versão atual" on public.matriz_risco for insert to authenticated
  with check ((select public.eh_redacao()) and por = (select auth.uid()) and exists (
    select 1 from public.materias m
    where m.id = materia_id and m.versao = matriz_risco.versao and m.status in ('rascunho', 'em_revisao')
  ));
create policy "matriz: redação corrige na versão atual" on public.matriz_risco for update to authenticated
  using ((select public.eh_redacao()))
  with check ((select public.eh_redacao()) and por = (select auth.uid()) and exists (
    select 1 from public.materias m
    where m.id = materia_id and m.versao = matriz_risco.versao and m.status in ('rascunho', 'em_revisao')
  ));

-- Revisão externa e aprovações: escrita só pelas funções -------------------------
grant select on public.revisores_atribuidos, public.assinaturas_revisor, public.aprovacoes to authenticated;
create policy "atribuição: redação lê" on public.revisores_atribuidos for select to authenticated
  using ((select public.eh_redacao()));
create policy "atribuição: revisor vê as suas" on public.revisores_atribuidos for select to authenticated
  using (revisor_id = (select auth.uid()));
create policy "assinatura: redação lê" on public.assinaturas_revisor for select to authenticated
  using ((select public.eh_redacao()));
create policy "assinatura: revisor vê as suas" on public.assinaturas_revisor for select to authenticated
  using (revisor_id = (select auth.uid()));
create policy "aprovação: redação lê" on public.aprovacoes for select to authenticated
  using ((select public.eh_redacao()));

-- Correções: as públicas são de todos -------------------------------------------
grant select on public.correcoes to anon, authenticated;
create policy "correção: público lê as públicas" on public.correcoes for select to anon
  using (publica);
create policy "correção: redação lê todas" on public.correcoes for select to authenticated
  using (publica or (select public.eh_redacao()));

-- Registro de alvos: redação lê, admin escreve (matriz de permissões do design) ---
grant select on public.registro_alvos to authenticated;
grant insert (materia_id, mes, tipo_alvo, campo_politico, decisao_nome, registrado_por) on public.registro_alvos to authenticated;
grant update (mes, tipo_alvo, campo_politico, decisao_nome, registrado_por) on public.registro_alvos to authenticated;
create policy "alvos: redação lê" on public.registro_alvos for select to authenticated
  using ((select public.eh_redacao()));
create policy "alvos: admin registra" on public.registro_alvos for insert to authenticated
  with check ((select public.eh_admin()) and registrado_por = (select auth.uid()));
create policy "alvos: admin corrige" on public.registro_alvos for update to authenticated
  using ((select public.eh_admin())) with check ((select public.eh_admin()) and registrado_por = (select auth.uid()));

-- Segurança editorial: leitura; escrita só pelas funções -------------------------
grant select on public.ocorrencias, public.log_editorial to authenticated;
grant select on public.notificacoes_juridicas to authenticated;
create policy "ocorrência: redação lê" on public.ocorrencias for select to authenticated
  using ((select public.eh_redacao()));
create policy "jurídico: só o admin" on public.notificacoes_juridicas for select to authenticated
  using ((select public.eh_admin()));
create policy "log: redação lê" on public.log_editorial for select to authenticated
  using ((select public.eh_redacao()));
