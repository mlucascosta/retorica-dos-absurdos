# ADR 0004 — Regras do manual no banco, testadas com PGlite

- **Status:** aceita
- **Data:** 2026-11-05

## Contexto

O manual tem regras que não podem depender de a interface estar certa: nenhuma matéria vai ao ar sem as quatro verificações; Categoria A com alvo identificável exige assinatura de um revisor externo que não escreveu a peça; menores ou vítimas na matriz de risco bloqueiam; o log editorial é a defesa jurídica do projeto.

## Decisão

- **Status só muda por funções** (`enviar_para_revisao`, `aprovar_materia`, `publicar_materia`, `retirar_materia` etc.). Um gatilho recusa qualquer mudança direta de status, inclusive do dono do banco.
- **Toda edição de conteúdo gera nova versão.** Verificações, matriz de risco, assinatura do revisor e aprovação valem para uma versão. Editou depois de aprovar: a matéria volta para rascunho e o controle recomeça.
- **`pendencias_aprovacao()`** lista o que falta para aprovar. A tela A06 mostra essa lista; `aprovar_materia()` recusa enquanto ela não estiver vazia.
- **Log editorial com cadeia de hash.** Só inserção (gatilho bloqueia update, delete e truncate). Cada linha guarda o SHA-256 da anterior; `verificar_log()` aponta a primeira linha adulterada.
- **Kill switch e jurídico** seguem o Addendum v1.1: nível 3 só pelo admin, retira a matéria do ar; prazos de 24 h, 72 h e 7 dias úteis.
- **Testes com PGlite** (Postgres compilado para WebAssembly, via npm), com `auth.uid()` e os papéis do Supabase simulados. Rodam no `npm test`, no CI, sem Docker.

## Consequências

- O PGlite é Postgres 18; o Supabase é 17. As migrações evitam recursos exclusivos do 18.
- Os testes simulam o Supabase, não o reproduzem. Os advisors do Supabase rodam no projeto de homologação a cada migração.
- Feriados não entram no prazo de 7 dias úteis; a tela jurídica avisa isso.
- Mudar uma regra exige migração nova e teste novo. É de propósito.
