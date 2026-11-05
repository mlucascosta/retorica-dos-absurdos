# ADR 0002 — Ajustes de contraste no tema do design

- **Status:** aceita, aguardando confirmação da direção editorial
- **Data:** 2026-11-05

## Contexto

O tema do design usa `#ff385c` como cor primária, com texto branco. O contraste é 3,52:1. O WCAG 2.2 AA exige 4,5:1 para texto normal. O elemento mais afetado é o selo SÁTIRA (texto branco, 10 px), que é também o elemento mais importante do site do ponto de vista jurídico: ele precisa ser lido em qualquer tela.

Secondary (`#00a699`), accent (`#fc642d`) e info (`#428bff`) com texto branco ficam entre 3,0 e 3,3.

## Decisão

- `--color-primary` passa a `#e31c5f`, o tom que o próprio design já usa nos links (4,57:1). `#ff385c` continua disponível como `--color-rausch` para elementos grandes.
- `--color-secondary-content`, `--color-accent-content` e `--color-info-content` passam a `#222222` (entre 4,8 e 5,3:1). As cores de fundo do design não mudam.

## Consequências

- `tests/tema.test.ts` recalcula todos os pares a cada PR. Uma mudança no tema que quebre o contraste reprova o CI.
- Para voltar ao `#ff385c` no selo, é preciso trocar também a cor do texto do selo ou aumentá-lo para texto grande (18,66 px em negrito).
