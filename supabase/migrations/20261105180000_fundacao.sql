-- M1 · 1/4 — Fundação: tipos, taxonomias, perfis e funções de papel.
-- Fonte: Manual Editorial v1.0, Addendum v1.1 e modelo de dados do design (sitemap).

-- Tipos -----------------------------------------------------------------------

create type public.papel as enum ('editor', 'admin', 'revisor_externo');
create type public.classificacao_temporal as enum ('quente', 'recorrente', 'atemporal', 'sazonal');
create type public.status_pauta as enum ('garimpo', 'verificada', 'em_producao', 'descartada', 'arquivada');
create type public.tipo_fonte as enum ('primaria', 'secundaria', 'rede_social');
create type public.categoria as enum ('A', 'B', 'C');
create type public.status_materia as enum (
  'com_angulo', 'formatada', 'rascunho', 'em_revisao', 'aprovada',
  'publicada', 'avaliada', 'descartada', 'arquivada', 'retirada'
);
create type public.tipo_verificacao as enum ('factual', 'humoristica', 'responsabilidade', 'editorial');
create type public.decisao_revisor as enum ('aprovar', 'devolver');
create type public.tipo_alvo as enum ('autoridade', 'instituicao', 'empresa', 'figura_publica', 'comportamento_coletivo');
create type public.campo_politico as enum ('governo', 'oposicao', 'neutro', 'nao_aplicavel');
create type public.decisao_nome as enum ('nomear', 'ficcionalizar', 'ficticio_obrigatorio');

-- Taxonomias (dados públicos do manual) -----------------------------------------

create table public.territorios (
  slug text primary key,
  nome text not null,
  descricao text not null,
  ordem smallint not null unique
);

create table public.formatos (
  numero smallint primary key check (numero between 1 and 8),
  slug text not null unique,
  nome text not null,
  tarja text
);

create table public.tecnicas (
  slug text primary key,
  nome text not null unique
);

insert into public.territorios (slug, nome, descricao, ordem) values
  ('politica-e-poder', 'Política e poder', 'Governos, Congresso, campanhas, discursos, promessas, decisões administrativas e a distância entre o que se diz e o que se faz.', 1),
  ('sociedade-e-cotidiano', 'Sociedade e cotidiano', 'Comportamento, família, trabalho, educação, consumo, relacionamentos, costumes e os hábitos que todo brasileiro reconhece.', 2),
  ('economia-e-consumo', 'Economia e consumo', 'Bancos, publicidade, preços, empresas, mercado de trabalho, empreendedorismo e promessas comerciais.', 3),
  ('tecnologia-e-internet', 'Tecnologia e internet', 'Inteligência artificial, redes sociais, influenciadores, aplicativos, cultura de produtividade, cursos e gurus digitais.', 4),
  ('cultura-e-mundo', 'Cultura e mundo', 'Cinema, música, televisão, celebridades, esportes, cultura popular e acontecimentos internacionais, com sotaque brasileiro.', 5);

insert into public.formatos (numero, slug, nome, tarja) values
  (1, 'noticia-absurda', 'Notícia absurda', null),
  (2, 'documentos-e-instituicoes', 'Documentos e instituições', 'DOCUMENTO FICTÍCIO — SÁTIRA'),
  (3, 'pesquisas-e-levantamentos', 'Pesquisas e levantamentos', 'PESQUISA INVENTADA'),
  (4, 'entrevistas-impossiveis', 'Entrevistas impossíveis', null),
  (5, 'listas-e-rankings', 'Listas e rankings', null),
  (6, 'observatorio-do-absurdo', 'Observatório do absurdo', null),
  (7, 'internet-em-estado-terminal', 'Internet em estado terminal', null),
  (8, 'a-realidade-supera-a-satira', 'A realidade supera a sátira', null);

insert into public.tecnicas (slug, nome) values
  ('exagero', 'Exagero'),
  ('literalizacao', 'Literalização'),
  ('inversao', 'Inversão'),
  ('burocratizacao', 'Burocratização'),
  ('eufemismo', 'Eufemismo'),
  ('precisao-absurda', 'Precisão absurda'),
  ('falsa-solenidade', 'Falsa solenidade'),
  ('escalada', 'Escalada'),
  ('contraste', 'Contraste'),
  ('autossatira', 'Autossátira'),
  ('incompetencia-institucional', 'Incompetência institucional'),
  ('hipocrisia', 'Hipocrisia');

-- Perfis -------------------------------------------------------------------------
-- Sem cadastro público: perfis nascem por convite do admin (M2).

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nome text not null check (length(trim(nome)) > 0),
  papel public.papel not null default 'editor',
  ativo boolean not null default true,
  criado_em timestamptz not null default now()
);

-- Funções de papel ----------------------------------------------------------------
-- security definer para poderem ler profiles de dentro de políticas RLS sem recursão.

create function public.papel_atual()
returns public.papel
language sql
stable
security definer
set search_path = ''
as $$
  select p.papel
  from public.profiles p
  where p.id = (select auth.uid()) and p.ativo
$$;

create function public.eh_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select public.papel_atual()) = 'admin', false)
$$;

create function public.eh_redacao()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select public.papel_atual()) in ('editor', 'admin'), false)
$$;

create function public.eh_revisor()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select public.papel_atual()) = 'revisor_externo', false)
$$;

-- Utilitário: atualizado_em ------------------------------------------------------

create function public.tocar_atualizado_em()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;
