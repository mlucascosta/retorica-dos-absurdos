# Segurança

## Como relatar uma vulnerabilidade

Não abra issue pública. Use o relato privado do GitHub: aba **Security** → **Report a vulnerability** neste repositório.

Responderemos em até 72 horas. Pedimos que a vulnerabilidade não seja divulgada antes da correção.

## Escopo

- O site público e o painel administrativo.
- Regras de acesso ao banco (RLS) descritas em `supabase/migrations`.
- Vazamento de dados pessoais ou de conteúdo editorial não publicado.

## O que fazemos se um segredo vazar

1. Revogamos a chave no serviço de origem imediatamente.
2. Só depois limpamos o histórico. Reescrever o histórico não basta: um repositório público pode ter sido clonado.
3. Registramos o incidente.
