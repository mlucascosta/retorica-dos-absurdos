# ADR 0001 — Stack: Nuxt 4, Node 26, Tailwind + daisyUI

- **Status:** aceita
- **Data:** 2026-11-05

## Contexto

O design do projeto (mockups 01–03 no Claude Design) foi desenhado em Next.js + Tailwind + daisyUI, com Ionicons, SweetAlert2 e Quill. A Vercel suporta Nuxt e Next sem configuração extra.

## Decisão

- **Nuxt 4.** Tailwind, daisyUI, Ionicons, SweetAlert2 e Quill não dependem de framework, então o contrato visual do design se mantém. As rotas de servidor do Nitro cobrem o painel sem uma camada extra, e `routeRules` cobre pré-renderização, ISR e cabeçalhos.
- **Node 26 LTS** (`engines.node: 26.x`, `.nvmrc` 26.13.0). A Vercel não fixa patch: aplica minors e patches automaticamente. A 26.13.0 é a 26.12.1 com o selo LTS.
- **TypeScript 6.x**, não 7. O TypeScript 7 mudou a API em JavaScript da qual a checagem de arquivos `.vue` depende. Reavaliar a cada release do `vue-tsc`.
- **Nuxt Content com SQLite nativo** (`node:sqlite`), sem módulo compilado.
- **Fontes e ícones empacotados no site** (`@fontsource`, `@iconify-json/ion`). O design carrega Google Fonts e Ionicons de CDN; aqui não, para não enviar o IP do leitor a terceiros e para manter a CSP restrita a `'self'`.

## Consequências

- O tema fica em `app/assets/css/theme.css`. Mudanças de identidade visual acontecem só ali.
- A página inicial carrega cerca de 140 KB de JavaScript comprimido, quase todo runtime do Vue. Reduzir isso (páginas institucionais sem JavaScript) fica para o M3.
