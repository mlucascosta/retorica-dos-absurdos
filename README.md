# Retórica dos Absurdos

Publicação brasileira de sátira. Este repositório é o site e o sistema editorial, construídos em público.

> A realidade não precisa de nossa ajuda para ser absurda.

Tudo o que é publicado aqui é sátira e vem identificado como tal. Quando uma peça parte de um fato real, a fonte original é identificada e arquivada.

## O que é público e o que não é

Este repositório é aberto porque o projeto é construído em público: código, migrações, decisões técnicas (`docs/adr`), roadmap e o diário de construção (`content/diario`).

Não estão aqui, nem nunca estarão: pautas, rascunhos, alvos em estudo, peças recusadas, pareceres jurídicos, dados de leitores, chaves ou senhas.

## Stack

- [Nuxt 4](https://nuxt.com) na [Vercel](https://vercel.com), Tailwind CSS 4 + daisyUI 5 (tema em `app/assets/css/theme.css`)
- Node.js 26 LTS (`engines.node: 26.x`; `.nvmrc` para desenvolvimento local)
- [Supabase](https://supabase.com) (Postgres com RLS, Auth, Storage) a partir do M1

## Rodando localmente

```bash
nvm use            # Node 26
npm ci
cp .env.example .env   # preencher só quando o M1 estiver no ar
npm run dev
```

Verificações antes de abrir um PR:

```bash
npm run lint
npm run typecheck
npm test
npm run build
```

## Fluxo de ramos (GitFlow simplificado)

| Ramo | Para quê | Deploy |
|---|---|---|
| `main` | produção | site público |
| `develop` | homologação | preview protegido |
| `feature/*` | trabalho novo, sai de `develop` | preview protegido |
| `release/vX.Y.Z` | fechamento de versão, sai de `develop`, entra em `main` e `develop` | preview protegido |
| `hotfix/vX.Y.Z` | correção urgente, sai de `main`, entra em `main` e `develop` | preview protegido |

Toda mudança relevante entra em [`CHANGELOG.md`](CHANGELOG.md), na seção [Não lançado]; o `release/*` move essas linhas para a versão nova.

Commits seguem [Conventional Commits](https://www.conventionalcommits.org/pt-br/) (`feat:`, `fix:`, `docs:`, `chore:`).

## Segurança

- Nenhum segredo entra no repositório. `.env.example` tem só os nomes das variáveis.
- O site não usa a chave `service_role` do Supabase. O acesso é controlado por RLS no banco.
- Vulnerabilidades: veja [SECURITY.md](SECURITY.md). Não abra issue pública para isso.
