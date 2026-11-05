-- M1 · 2/4 — Tabelas editoriais: pautas, fontes, matérias, versões, verificações,
-- revisão externa, aprovações, correções, registro de alvos, ocorrências,
-- notificações jurídicas e log editorial.

-- Pautas (passos 1–2 da folha operacional) ----------------------------------------

create table public.pautas (
  id bigint generated always as identity primary key,
  titulo text not null check (length(trim(titulo)) > 0),
  territorio text not null references public.territorios (slug),
  classificacao public.classificacao_temporal not null,
  status public.status_pauta not null default 'garimpo',
  responsavel uuid references public.profiles (id),
  prazo timestamptz,
  motivo_encerramento text,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  constraint pauta_encerrada_tem_motivo
    check (status not in ('descartada', 'arquivada') or motivo_encerramento is not null)
);
create index pautas_status_idx on public.pautas (status);
create index pautas_responsavel_idx on public.pautas (responsavel);
create index pautas_territorio_idx on public.pautas (territorio);

create table public.fontes (
  id bigint generated always as identity primary key,
  pauta_id bigint not null references public.pautas (id) on delete cascade,
  url text not null check (url ~* '^https?://'),
  nome text not null,
  tipo public.tipo_fonte not null,
  coletado_em timestamptz not null default now(),
  trecho text,
  confirmada_por_independente boolean not null default false
);
create index fontes_pauta_idx on public.fontes (pauta_id);

-- Arquivamento triplo: captura própria (Storage), backup externo, Wayback Machine.
create table public.arquivos_fonte (
  fonte_id bigint primary key references public.fontes (id) on delete cascade,
  captura_path text,
  captura_sha256 text check (captura_sha256 ~ '^[0-9a-f]{64}$'),
  backup_ok boolean not null default false,
  wayback_url text check (wayback_url ~* '^https://web\.archive\.org/'),
  arquivado_em timestamptz not null default now()
);

-- Matérias ------------------------------------------------------------------------

create table public.materias (
  id bigint generated always as identity primary key,
  pauta_id bigint references public.pautas (id),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  manchete text not null check (length(trim(manchete)) > 0),
  subtitulo text,
  mov_realidade text,
  mov_contradicao text,
  mov_extrapolacao text,
  mov_escalada text,
  mov_arremate text,
  corpo text,
  formato smallint not null references public.formatos (numero),
  tecnica text references public.tecnicas (slug),
  tecnica_complementar text references public.tecnicas (slug),
  territorio text not null references public.territorios (slug),
  categoria public.categoria not null,
  alvo_descricao text,
  alvo_identificavel boolean not null default false,
  pessoa_identificavel boolean not null default false,
  imagem_ia boolean not null default false,
  anuncios_ativos boolean not null default false,
  motivo_sem_ads text,
  status public.status_materia not null default 'rascunho',
  versao integer not null default 1,
  autor_id uuid not null references public.profiles (id),
  publicada_em timestamptz,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  constraint categoria_a_tem_pauta check (categoria <> 'A' or pauta_id is not null),
  constraint publicada_tem_data check (status <> 'publicada' or publicada_em is not null)
);
create index materias_status_idx on public.materias (status);
create index materias_autor_idx on public.materias (autor_id);
create index materias_pauta_idx on public.materias (pauta_id);
create index materias_publicadas_idx on public.materias (publicada_em desc) where status = 'publicada';

create table public.materia_versoes (
  materia_id bigint not null references public.materias (id) on delete cascade,
  numero integer not null,
  conteudo jsonb not null,
  autor_id uuid references public.profiles (id),
  criado_em timestamptz not null default now(),
  primary key (materia_id, numero)
);

-- Controle editorial (passo 6) ------------------------------------------------------
-- Toda verificação, assinatura e aprovação vale para UMA versão da matéria.

create table public.verificacoes (
  materia_id bigint not null references public.materias (id) on delete cascade,
  versao integer not null,
  tipo public.tipo_verificacao not null,
  itens jsonb not null default '{}'::jsonb,
  ok boolean not null,
  por uuid not null references public.profiles (id),
  em timestamptz not null default now(),
  primary key (materia_id, versao, tipo)
);

create table public.matriz_risco (
  materia_id bigint not null references public.materias (id) on delete cascade,
  versao integer not null,
  aparencia_fisica boolean not null,
  menores_ou_familiares boolean not null,
  vitimas_identificaveis boolean not null,
  pessoa_privada boolean not null,
  instituicao_real text check (instituicao_real in ('nomeada', 'ficcionalizada', 'ficticia', 'nenhuma')),
  por uuid not null references public.profiles (id),
  em timestamptz not null default now(),
  primary key (materia_id, versao)
);

create table public.revisores_atribuidos (
  materia_id bigint not null references public.materias (id) on delete cascade,
  revisor_id uuid not null references public.profiles (id),
  atribuido_por uuid not null references public.profiles (id),
  atribuido_em timestamptz not null default now(),
  primary key (materia_id, revisor_id)
);
create index revisores_atribuidos_revisor_idx on public.revisores_atribuidos (revisor_id);

create table public.assinaturas_revisor (
  materia_id bigint not null references public.materias (id) on delete cascade,
  versao integer not null,
  revisor_id uuid not null references public.profiles (id),
  decisao public.decisao_revisor not null,
  comentario text,
  assinado_em timestamptz not null default now(),
  primary key (materia_id, versao, revisor_id)
);
create index assinaturas_revisor_revisor_idx on public.assinaturas_revisor (revisor_id);

create table public.aprovacoes (
  materia_id bigint not null references public.materias (id) on delete cascade,
  versao integer not null,
  admin_id uuid not null references public.profiles (id),
  aprovado_em timestamptz not null default now(),
  primary key (materia_id, versao)
);

-- Correções e registro de alvos ------------------------------------------------------

create table public.correcoes (
  id bigint generated always as identity primary key,
  materia_id bigint not null references public.materias (id),
  tipo text not null check (tipo in ('fato_de_origem', 'identificacao', 'atribuicao', 'outro')),
  antes text not null,
  depois text not null,
  nota_publica text,
  publica boolean not null default true,
  por uuid not null references public.profiles (id),
  publicada_em timestamptz not null default now()
);
create index correcoes_materia_idx on public.correcoes (materia_id);

create table public.registro_alvos (
  materia_id bigint primary key references public.materias (id) on delete cascade,
  mes date not null check (extract(day from mes) = 1),
  tipo_alvo public.tipo_alvo not null,
  campo_politico public.campo_politico not null,
  decisao_nome public.decisao_nome not null,
  registrado_por uuid not null references public.profiles (id),
  registrado_em timestamptz not null default now()
);
create index registro_alvos_mes_idx on public.registro_alvos (mes);

-- Segurança editorial -------------------------------------------------------------

create table public.ocorrencias (
  id bigint generated always as identity primary key,
  materia_id bigint not null references public.materias (id),
  nivel smallint not null check (nivel between 1 and 3),
  descricao text not null,
  acao text,
  aberta boolean not null default true,
  monitorar_ate timestamptz,
  aberta_por uuid not null references public.profiles (id),
  aberta_em timestamptz not null default now(),
  encerrada_em timestamptz
);
create index ocorrencias_materia_idx on public.ocorrencias (materia_id);

create table public.notificacoes_juridicas (
  id bigint generated always as identity primary key,
  materia_id bigint references public.materias (id),
  origem text not null,
  nivel smallint not null check (nivel between 1 and 3),
  recebida_em timestamptz not null default now(),
  prazo_em timestamptz not null,
  parecer text,
  decisao text check (decisao in ('sustentar', 'retratar', 'esclarecer', 'suspender')),
  decidida_em timestamptz,
  anexo_path text,
  registrada_por uuid not null references public.profiles (id)
);
create index notificacoes_juridicas_materia_idx on public.notificacoes_juridicas (materia_id);

-- Log editorial: só inserção, cadeia de hash ---------------------------------------

create table public.log_editorial (
  numero bigint generated always as identity primary key,
  entidade text not null,
  ref text not null,
  acao text not null,
  motivo text,
  por uuid references public.profiles (id),
  em timestamptz not null default now(),
  hash_anterior text not null,
  hash text not null unique
);
create index log_editorial_ref_idx on public.log_editorial (entidade, ref);
create index log_editorial_por_idx on public.log_editorial (por);

-- Gatilhos de atualizado_em
create trigger pautas_atualizado_em before update on public.pautas
  for each row execute function public.tocar_atualizado_em();
create trigger materias_atualizado_em before update on public.materias
  for each row execute function public.tocar_atualizado_em();
