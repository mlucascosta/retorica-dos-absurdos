# ADR 0003 — Nenhuma chave service_role no site

- **Status:** aceita (vale a partir do M1)
- **Data:** 2026-11-05

## Contexto

O painel editorial precisa escrever no banco. O caminho mais curto é dar às rotas de servidor a chave `service_role` do Supabase, que ignora todas as regras de acesso.

## Decisão

O site não usa a `service_role`. O painel usa a sessão do próprio usuário, e as políticas de RLS decidem o que cada papel (editor, admin, revisor externo) pode fazer. As regras do manual que bloqueiam publicação (quatro verificações, assinatura do revisor externo quando exigida) ficam em funções SQL, não só na interface.

Migrações rodam pelo CI com a senha do banco guardada nos segredos do GitHub Actions, nunca na Vercel.

## Consequências

- Uma falha numa rota de servidor não vira acesso total ao banco.
- Se a interface tiver um bug que deixe publicar sem verificação, o banco recusa mesmo assim.
- Rotas que precisam de privilégio elevado (por exemplo, o envio da newsletter) usam funções SQL específicas com `security definer` e escopo mínimo, revisadas uma a uma.
