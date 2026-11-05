#!/usr/bin/env node
// Barreira automática do build in public: o diário é público e não pode vazar
// chaves, URLs de projeto, e-mails ou identificadores internos.
// Não substitui o checklist humano do PR (pauta, alvo e recusa não se detectam por regex).

import { readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'

const pasta = process.argv[2] ?? 'content'

const proibidos = [
  { nome: 'URL de projeto Supabase', re: /[a-z0-9]{20}\.supabase\.(co|in)/i },
  { nome: 'chave service_role ou secreta', re: /service_role|sb_secret_/i },
  { nome: 'JWT', re: /eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}/ },
  { nome: 'chave de API', re: /\b(sk|pk|rk)[-_](live|test|or|proj)?[-_]?[A-Za-z0-9]{16,}/ },
  { nome: 'token do GitHub', re: /gh[pousr]_[A-Za-z0-9]{30,}/ },
  { nome: 'e-mail', re: /[A-Za-z0-9._%+-]+@(?!users\.noreply\.github\.com)[A-Za-z0-9.-]+\.[A-Za-z]{2,}/ },
  { nome: 'ID de projeto Vercel', re: /prj_[A-Za-z0-9]{20,}/ },
  { nome: 'ID de deploy Vercel', re: /dpl_[A-Za-z0-9]{20,}/ },
]

function arquivos(dir) {
  return readdirSync(dir, { withFileTypes: true }).flatMap(e =>
    e.isDirectory() ? arquivos(join(dir, e.name)) : /\.(md|mdx|ya?ml|json)$/.test(e.name) ? [join(dir, e.name)] : [],
  )
}

let falhas = 0
for (const arquivo of arquivos(pasta)) {
  const linhas = readFileSync(arquivo, 'utf8').split('\n')
  linhas.forEach((linha, i) => {
    for (const { nome, re } of proibidos) {
      if (re.test(linha)) {
        console.error(`${arquivo}:${i + 1}: possível ${nome}`)
        falhas++
      }
    }
  })
}

if (falhas) {
  console.error(`\n${falhas} ocorrência(s). Conteúdo público não pode conter isso.`)
  process.exit(1)
}
console.log(`Conteúdo verificado: nenhum padrão proibido em ${pasta}/.`)
