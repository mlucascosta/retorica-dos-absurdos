-- M1 · 5 — Ajustes dos advisors do Supabase (homologação, 2026-11-05).
--
-- Segurança: os avisos "authenticated_security_definer_function_executable" são intencionais.
-- As funções de transição SÃO a API do painel e conferem o papel por dentro (exigir eh_admin,
-- eh_redacao, eh_revisor). As auxiliares que abrem a transição não são executáveis pelo app.

-- Índices para chaves estrangeiras (unindexed_foreign_keys) --------------------
create index aprovacoes_admin_idx on public.aprovacoes (admin_id);
create index correcoes_por_idx on public.correcoes (por);
create index materia_versoes_autor_idx on public.materia_versoes (autor_id);
create index materias_formato_idx on public.materias (formato);
create index materias_tecnica_idx on public.materias (tecnica);
create index materias_tecnica_complementar_idx on public.materias (tecnica_complementar);
create index materias_territorio_idx on public.materias (territorio);
create index matriz_risco_por_idx on public.matriz_risco (por);
create index notificacoes_juridicas_registrada_por_idx on public.notificacoes_juridicas (registrada_por);
create index ocorrencias_aberta_por_idx on public.ocorrencias (aberta_por);
create index registro_alvos_registrado_por_idx on public.registro_alvos (registrado_por);
create index revisores_atribuidos_atribuido_por_idx on public.revisores_atribuidos (atribuido_por);
create index verificacoes_por_idx on public.verificacoes (por);

-- Uma política de leitura por tabela (multiple_permissive_policies) -------------
-- Mesma regra de antes: a redação lê tudo; o revisor externo, só o que foi atribuído a ele.

drop policy "matéria: redação lê todas" on public.materias;
drop policy "matéria: revisor lê as atribuídas" on public.materias;
create policy "matéria: redação lê todas; revisor, as atribuídas" on public.materias for select to authenticated
  using (
    (select public.eh_redacao())
    or ((select public.eh_revisor()) and exists (
      select 1 from public.revisores_atribuidos r where r.materia_id = materias.id and r.revisor_id = (select auth.uid())
    ))
  );

drop policy "versão: redação lê" on public.materia_versoes;
drop policy "versão: revisor lê as atribuídas" on public.materia_versoes;
create policy "versão: redação lê todas; revisor, as atribuídas" on public.materia_versoes for select to authenticated
  using (
    (select public.eh_redacao())
    or ((select public.eh_revisor()) and exists (
      select 1 from public.revisores_atribuidos r where r.materia_id = materia_versoes.materia_id and r.revisor_id = (select auth.uid())
    ))
  );

drop policy "verificação: redação lê" on public.verificacoes;
drop policy "verificação: revisor lê as atribuídas" on public.verificacoes;
create policy "verificação: redação lê todas; revisor, as atribuídas" on public.verificacoes for select to authenticated
  using (
    (select public.eh_redacao())
    or ((select public.eh_revisor()) and exists (
      select 1 from public.revisores_atribuidos r where r.materia_id = verificacoes.materia_id and r.revisor_id = (select auth.uid())
    ))
  );

drop policy "matriz: redação lê" on public.matriz_risco;
drop policy "matriz: revisor lê as atribuídas" on public.matriz_risco;
create policy "matriz: redação lê todas; revisor, as atribuídas" on public.matriz_risco for select to authenticated
  using (
    (select public.eh_redacao())
    or ((select public.eh_revisor()) and exists (
      select 1 from public.revisores_atribuidos r where r.materia_id = matriz_risco.materia_id and r.revisor_id = (select auth.uid())
    ))
  );

drop policy "atribuição: redação lê" on public.revisores_atribuidos;
drop policy "atribuição: revisor vê as suas" on public.revisores_atribuidos;
create policy "atribuição: redação lê todas; revisor, as suas" on public.revisores_atribuidos for select to authenticated
  using ((select public.eh_redacao()) or revisor_id = (select auth.uid()));

drop policy "assinatura: redação lê" on public.assinaturas_revisor;
drop policy "assinatura: revisor vê as suas" on public.assinaturas_revisor;
create policy "assinatura: redação lê todas; revisor, as suas" on public.assinaturas_revisor for select to authenticated
  using ((select public.eh_redacao()) or revisor_id = (select auth.uid()));
