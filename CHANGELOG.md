# Changelog

Todas as mudanças relevantes do site e do sistema editorial do Retórica dos Absurdos.

O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o projeto usa [versionamento semântico](https://semver.org/lang/pt-BR/). Cada versão corresponde a um `release/vX.Y.Z` do GitFlow que entrou em `main`.

Este arquivo registra o que mudou no **código**. Decisões editoriais (pautas, recusas, correções de matérias) não entram aqui: as correções públicas ficam em `/correcoes` no site.

## [Não lançado]

### Adicionado

- **M1 — Banco de dados.** Modelo do design (pautas, fontes com arquivamento triplo, matérias, versões, verificações, matriz de risco, revisor externo, aprovações, correções, registro de alvos, ocorrências, notificações jurídicas, log editorial).
- Regras do manual no próprio banco: o status de uma matéria só muda por funções que exigem as quatro verificações, a matriz de risco, a assinatura do revisor externo (Categoria A com alvo identificável) e a fonte com arquivamento triplo. Nem o dono do banco consegue pular isso.
- Verificações, assinatura e aprovação valem para uma versão da matéria. Uma edição depois da aprovação devolve a matéria para rascunho.
- Kill switch em três níveis (nível 3 só pelo admin, retira a matéria do ar) e prazos jurídicos de 24 h, 72 h e 7 dias úteis, conforme o Addendum v1.1.
- Log editorial só de inserção, com cadeia de hash e `verificar_log()` para provar que não foi adulterado.
- RLS por papel (leitor anônimo, editor, admin, revisor externo) e privilégios por coluna: o leitor anônimo só vê matérias publicadas e só as colunas do site.
- 36 testes de banco com PGlite (Postgres em WebAssembly), rodando no CI sem Docker.
- Projeto Supabase de homologação com as migrações aplicadas e os advisors conferidos.
- ADR 0004 (regras no banco) e este changelog.

## [0.1.0] — M0 · Fundação

Em `develop` desde o PR #1. Vai para produção pelo PR #3 (`develop` → `main`), depois da ligação da Vercel com o GitHub.

### Adicionado

- Site em Nuxt 4 com Node.js 26 LTS na Vercel, funções em São Paulo (`gru1`).
- Contrato visual do Claude Design: tema daisyUI "retorica", barra superior com o selo SÁTIRA, wordmark, menu, rodapé, tarjas de formato, espaço de anúncio (desligado) e a página 404 "Ofício nº 404".
- Páginas exigidas pelo manual antes de qualquer matéria: manifesto e as doze regras, política editorial, política de correções, identificação de sátira, privacidade, territórios e formatos.
- Diário de construção (`/diario`) com o primeiro post.
- Cabeçalhos de segurança (CSP restrita, HSTS, X-Frame-Options), fontes e ícones servidos pelo próprio site, sem CDN.
- CI com lint, checagem de tipos, testes, build em Node 26, auditoria de dependências (audit-ci) e varredura de segredos (gitleaks).
- Teste automático do contraste do tema (WCAG 2.2 AA).
- ADRs 0001 a 0003.

### Alterado em relação ao design

- Cor do selo SÁTIRA e dos botões de `#ff385c` para `#e31c5f`, e texto escuro sobre secondary, accent e info, por contraste (ADR 0002).

[Não lançado]: https://github.com/mlucascosta/retorica-dos-absurdos/compare/main...develop
[0.1.0]: https://github.com/mlucascosta/retorica-dos-absurdos/pull/1
