import { readdirSync, readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { join } from 'node:path'
import { PGlite } from '@electric-sql/pglite'

// Postgres real (WASM) com as peças do Supabase que as migrações usam:
// papéis anon/authenticated, auth.users, auth.uid() e os privilégios padrão do schema public.
const STUB_SUPABASE = `
  create role anon nologin;
  create role authenticated nologin;
  create role service_role nologin bypassrls;
  create schema auth;
  create table auth.users (id uuid primary key);
  create function auth.uid() returns uuid language sql stable as $$
    select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
  $$;
  grant usage on schema auth to anon, authenticated;
  grant execute on function auth.uid() to anon, authenticated;
  grant usage on schema public to anon, authenticated;
  -- O Supabase concede tudo por padrão; as migrações precisam revogar.
  alter default privileges in schema public grant all on tables to anon, authenticated;
  alter default privileges in schema public grant all on sequences to anon, authenticated;
  alter default privileges in schema public grant all on functions to anon, authenticated;
`

const PASTA_MIGRACOES = fileURLToPath(new URL('../../supabase/migrations', import.meta.url))

export const USUARIOS = {
  admin: '00000000-0000-4000-8000-00000000000a',
  editor: '00000000-0000-4000-8000-00000000000e',
  editora2: '00000000-0000-4000-8000-0000000000e2',
  revisor: '00000000-0000-4000-8000-00000000000f',
  revisor2: '00000000-0000-4000-8000-0000000000f2',
} as const

export type Usuario = keyof typeof USUARIOS

export async function criarBanco() {
  const db = new PGlite()
  await db.exec(STUB_SUPABASE)
  for (const arquivo of readdirSync(PASTA_MIGRACOES).filter(a => a.endsWith('.sql')).sort()) {
    await db.exec(readFileSync(join(PASTA_MIGRACOES, arquivo), 'utf8'))
  }
  const perfis: [Usuario, string, string][] = [
    ['admin', 'Direção Fictícia', 'admin'],
    ['editor', 'Editor Fictício', 'editor'],
    ['editora2', 'Editora Fictícia', 'editor'],
    ['revisor', 'Revisora Externa Fictícia', 'revisor_externo'],
    ['revisor2', 'Revisor Não Atribuído', 'revisor_externo'],
  ]
  for (const [chave, nome, papel] of perfis) {
    await db.query('insert into auth.users (id) values ($1)', [USUARIOS[chave]])
    await db.query('insert into public.profiles (id, nome, papel) values ($1, $2, $3)', [USUARIOS[chave], nome, papel])
  }
  return db
}

/** Executa como um usuário logado (papel authenticated + sub do JWT). */
export async function como<T>(db: PGlite, quem: Usuario | 'anon', fn: () => Promise<T>): Promise<T> {
  await db.query(`select set_config('request.jwt.claim.sub', $1, false)`, [quem === 'anon' ? '' : USUARIOS[quem]])
  await db.exec(`set role ${quem === 'anon' ? 'anon' : 'authenticated'}`)
  try {
    return await fn()
  }
  finally {
    await db.exec('reset role')
    await db.query(`select set_config('request.jwt.claim.sub', '', false)`)
  }
}

export async function linhas<T = Record<string, unknown>>(db: PGlite, sql: string, params: unknown[] = []) {
  return (await db.query<T>(sql, params)).rows
}
