import type { PGlite } from '@electric-sql/pglite'
import { beforeAll, describe, expect, it } from 'vitest'
import { como, criarBanco, linhas, USUARIOS } from './banco'

// Percorre o fluxo da folha operacional (8 passos) e tenta furar cada regra.
// Os testes dependem um do outro em ordem: é o ciclo de vida de uma matéria.

let db: PGlite
let pautaId: number
let fonteId: number
let materiaId: number

const MOVIMENTOS = {
  mov_realidade: 'Banco fictício enviou comunicado sobre cobrança indevida.',
  mov_contradicao: 'Chama erro de ajuste técnico.',
  mov_extrapolacao: 'A devolução vira compensação simbólica.',
  mov_escalada: 'O valor médio é de R$ 4,82.',
  mov_arremate: 'Segue comprometido com a transparência, nesta ordem aproximada.',
}

beforeAll(async () => {
  db = await criarBanco()
}, 60_000)

describe('acesso anônimo', () => {
  it('lê taxonomias', async () => {
    const r = await como(db, 'anon', () => linhas(db, 'select count(*)::int as n from public.formatos'))
    expect(r[0]).toEqual({ n: 8 })
  })

  it('não lê pautas nem o log', async () => {
    await expect(como(db, 'anon', () => linhas(db, 'select * from public.pautas'))).rejects.toThrow(/permission denied/)
    await expect(como(db, 'anon', () => linhas(db, 'select * from public.log_editorial'))).rejects.toThrow(/permission denied/)
  })

  it('não executa funções de transição', async () => {
    await expect(como(db, 'anon', () => linhas(db, 'select public.publicar_materia(1)'))).rejects.toThrow(/permission denied/)
  })
})

describe('passos 1–2: pauta', () => {
  it('editor cria pauta em garimpo; quente ganha prazo de 48h', async () => {
    const r = await como(db, 'editor', () => linhas<{ id: number, prazo: string | null }>(db,
      `insert into public.pautas (titulo, territorio, classificacao, responsavel)
       values ('Banco fictício e o ajuste técnico', 'economia-e-consumo', 'quente', $1)
       returning id, prazo`, [USUARIOS.editor]))
    pautaId = r[0]!.id
    expect(r[0]!.prazo).not.toBeNull()
  })

  it('editor não muda status direto', async () => {
    await expect(como(db, 'editor', () => linhas(db, `update public.pautas set status = 'verificada' where id = $1`, [pautaId])))
      .rejects.toThrow(/permission denied/)
  })

  it('verificação bloqueia sem fonte confirmada com arquivamento triplo', async () => {
    await expect(como(db, 'editor', () => linhas(db, 'select public.verificar_pauta($1)', [pautaId])))
      .rejects.toThrow(/Checkpoint não pulável/)

    const f = await como(db, 'editor', () => linhas<{ id: number }>(db,
      `insert into public.fontes (pauta_id, url, nome, tipo, trecho, confirmada_por_independente)
       values ($1, 'https://exemplo.invalid/comunicado', 'Comunicado fictício', 'primaria', 'ajuste técnico', true)
       returning id`, [pautaId]))
    fonteId = f[0]!.id

    // Só captura e backup: ainda falta o Wayback.
    await como(db, 'editor', () => linhas(db,
      `insert into public.arquivos_fonte (fonte_id, captura_path, captura_sha256, backup_ok)
       values ($1, 'capturas/1.png', repeat('a', 64), true)`, [fonteId]))
    await expect(como(db, 'editor', () => linhas(db, 'select public.verificar_pauta($1)', [pautaId])))
      .rejects.toThrow(/Checkpoint não pulável/)
  })

  it('com o arquivamento triplo completo, a pauta é verificada', async () => {
    await como(db, 'editor', () => linhas(db,
      `update public.arquivos_fonte set wayback_url = 'https://web.archive.org/web/2026/exemplo' where fonte_id = $1`, [fonteId]))
    await como(db, 'editor', () => linhas(db, 'select public.verificar_pauta($1)', [pautaId]))
    const r = await linhas(db, 'select status from public.pautas where id = $1', [pautaId])
    expect(r[0]).toEqual({ status: 'verificada' })
  })

  it('descarte sem motivo é recusado', async () => {
    await expect(como(db, 'editor', () => linhas(db, `select public.encerrar_pauta($1, 'descartada', '  ')`, [pautaId])))
      .rejects.toThrow(/Motivo obrigatório/)
  })
})

describe('passos 3–5: matéria', () => {
  it('editor só cria matéria em nome próprio', async () => {
    await expect(como(db, 'editor', () => linhas(db,
      `insert into public.materias (pauta_id, slug, manchete, formato, territorio, categoria, autor_id)
       values ($1, 'outra', 'Outra', 1, 'economia-e-consumo', 'A', $2)`, [pautaId, USUARIOS.editora2])))
      .rejects.toThrow(/row-level security/)
  })

  it('editor cria matéria Categoria A; pauta passa a em_producao; versão 1 registrada', async () => {
    const r = await como(db, 'editor', () => linhas<{ id: number, versao: number, status: string }>(db,
      `insert into public.materias (pauta_id, slug, manchete, formato, tecnica, territorio, categoria,
                                    alvo_descricao, alvo_identificavel, autor_id)
       values ($1, 'banco-ajuste-tecnico', 'Banco descreve cobrança indevida como ajuste técnico', 1, 'eufemismo',
               'economia-e-consumo', 'A', 'Instituição financeira fictícia', true, $2)
       returning id, versao, status`, [pautaId, USUARIOS.editor]))
    materiaId = r[0]!.id
    expect(r[0]).toMatchObject({ versao: 1, status: 'rascunho' })
    expect(await linhas(db, 'select status from public.pautas where id = $1', [pautaId])).toEqual([{ status: 'em_producao' }])
    expect(await linhas(db, 'select numero from public.materia_versoes where materia_id = $1', [materiaId])).toEqual([{ numero: 1 }])
  })

  it('não vai para revisão sem os cinco movimentos', async () => {
    await expect(como(db, 'editor', () => linhas(db, 'select public.enviar_para_revisao($1)', [materiaId])))
      .rejects.toThrow(/cinco movimentos/)
  })

  it('cada edição de conteúdo gera nova versão', async () => {
    await como(db, 'editor', () => linhas(db,
      `update public.materias set mov_realidade = $2, mov_contradicao = $3, mov_extrapolacao = $4,
              mov_escalada = $5, mov_arremate = $6 where id = $1`,
      [materiaId, ...Object.values(MOVIMENTOS)]))
    expect(await linhas(db, 'select versao from public.materias where id = $1', [materiaId])).toEqual([{ versao: 2 }])
  })

  it('ninguém muda status direto, nem o dono do banco', async () => {
    await expect(como(db, 'editor', () => linhas(db, `update public.materias set status = 'publicada' where id = $1`, [materiaId])))
      .rejects.toThrow(/permission denied/)
    await expect(linhas(db, `update public.materias set status = 'publicada', publicada_em = now() where id = $1`, [materiaId]))
      .rejects.toThrow(/só muda pelas funções de transição/)
  })

  it('editor envia para revisão', async () => {
    await como(db, 'editor', () => linhas(db, 'select public.enviar_para_revisao($1)', [materiaId]))
    expect(await linhas(db, 'select status from public.materias where id = $1', [materiaId])).toEqual([{ status: 'em_revisao' }])
  })
})

describe('passo 6: controle editorial', () => {
  it('editor não aprova', async () => {
    await expect(como(db, 'editor', () => linhas(db, 'select public.aprovar_materia($1)', [materiaId])))
      .rejects.toThrow(/Só o admin/)
  })

  it('admin vê as pendências e é bloqueado por elas', async () => {
    const r = await como(db, 'admin', () => linhas<{ p: string[] }>(db, 'select public.pendencias_aprovacao($1) as p', [materiaId]))
    const texto = r[0]!.p.join(' | ')
    expect(texto).toMatch(/Verificação factual/)
    expect(texto).toMatch(/Matriz de risco/)
    expect(texto).toMatch(/Revisor externo obrigatório/)
    await expect(como(db, 'admin', () => linhas(db, 'select public.aprovar_materia($1)', [materiaId])))
      .rejects.toThrow(/Aprovação bloqueada/)
  })

  it('verificações só valem para a versão atual', async () => {
    await expect(como(db, 'editor', () => linhas(db,
      `insert into public.verificacoes (materia_id, versao, tipo, ok, por) values ($1, 1, 'factual', true, $2)`,
      [materiaId, USUARIOS.editor]))).rejects.toThrow(/row-level security/)
  })

  it('editor preenche as quatro verificações e a matriz (com menores marcado)', async () => {
    await como(db, 'editor', async () => {
      for (const tipo of ['factual', 'humoristica', 'responsabilidade', 'editorial']) {
        await linhas(db, `insert into public.verificacoes (materia_id, versao, tipo, ok, por) values ($1, 2, $2, true, $3)`,
          [materiaId, tipo, USUARIOS.editor])
      }
      await linhas(db,
        `insert into public.matriz_risco (materia_id, versao, aparencia_fisica, menores_ou_familiares,
                                          vitimas_identificaveis, pessoa_privada, instituicao_real, por)
         values ($1, 2, false, true, false, false, 'ficcionalizada', $2)`, [materiaId, USUARIOS.editor])
    })
    const r = await como(db, 'admin', () => linhas<{ p: string[] }>(db, 'select public.pendencias_aprovacao($1) as p', [materiaId]))
    expect(r[0]!.p.join(' | ')).toMatch(/menores ou familiares/)
  })

  it('revisor não atribuído não lê nem assina', async () => {
    expect(await como(db, 'revisor', () => linhas(db, 'select id from public.materias'))).toEqual([])
    await expect(como(db, 'revisor', () => linhas(db, `select public.assinar_revisao($1, 'aprovar')`, [materiaId])))
      .rejects.toThrow(/não foi atribuída/)
  })

  it('só pessoa com papel revisor_externo pode ser atribuída', async () => {
    await expect(como(db, 'admin', () => linhas(db, 'select public.atribuir_revisor($1, $2)', [materiaId, USUARIOS.editora2])))
      .rejects.toThrow(/revisor_externo/)
  })

  it('revisor atribuído lê a matéria, mas não pautas nem log', async () => {
    await como(db, 'admin', () => linhas(db, 'select public.atribuir_revisor($1, $2)', [materiaId, USUARIOS.revisor]))
    expect(await como(db, 'revisor', () => linhas(db, 'select id from public.materias'))).toEqual([{ id: materiaId }])
    expect(await como(db, 'revisor', () => linhas(db, 'select id from public.pautas'))).toEqual([])
    expect(await como(db, 'revisor', () => linhas(db, 'select numero from public.log_editorial'))).toEqual([])
  })

  it('revisor não grava assinatura direto na tabela', async () => {
    await expect(como(db, 'revisor', () => linhas(db,
      `insert into public.assinaturas_revisor (materia_id, versao, revisor_id, decisao) values ($1, 2, $2, 'aprovar')`,
      [materiaId, USUARIOS.revisor]))).rejects.toThrow(/permission denied/)
  })

  it('com menores marcados, nem a assinatura libera a aprovação', async () => {
    await como(db, 'revisor', () => linhas(db, `select public.assinar_revisao($1, 'aprovar')`, [materiaId]))
    await expect(como(db, 'admin', () => linhas(db, 'select public.aprovar_materia($1)', [materiaId])))
      .rejects.toThrow(/menores ou familiares/)
  })

  it('trecho retirado (nova versão) derruba verificações e assinatura anteriores', async () => {
    await como(db, 'editor', () => linhas(db, `update public.materias set corpo = 'Texto sem o trecho.' where id = $1`, [materiaId]))
    const m = await linhas(db, 'select status, versao from public.materias where id = $1', [materiaId])
    expect(m).toEqual([{ status: 'rascunho', versao: 3 }])
    const log = await linhas(db, `select acao from public.log_editorial where ref = $1 order by numero desc limit 1`, [String(materiaId)])
    expect(log).toEqual([{ acao: 'voltou_para_rascunho' }])
  })

  it('versão 3 completa: verificações, matriz limpa, revisor assina, admin aprova', async () => {
    await como(db, 'editor', async () => {
      await linhas(db, 'select public.enviar_para_revisao($1)', [materiaId])
      for (const tipo of ['factual', 'humoristica', 'responsabilidade', 'editorial']) {
        await linhas(db, `insert into public.verificacoes (materia_id, versao, tipo, ok, por) values ($1, 3, $2, true, $3)`,
          [materiaId, tipo, USUARIOS.editor])
      }
      await linhas(db,
        `insert into public.matriz_risco (materia_id, versao, aparencia_fisica, menores_ou_familiares,
                                          vitimas_identificaveis, pessoa_privada, instituicao_real, por)
         values ($1, 3, false, false, false, false, 'ficcionalizada', $2)`, [materiaId, USUARIOS.editor])
    })
    // A assinatura da versão 2 não vale para a 3.
    await expect(como(db, 'admin', () => linhas(db, 'select public.aprovar_materia($1)', [materiaId])))
      .rejects.toThrow(/falta assinatura na versão 3/)
    await como(db, 'revisor', () => linhas(db, `select public.assinar_revisao($1, 'aprovar')`, [materiaId]))
    await como(db, 'admin', () => linhas(db, 'select public.aprovar_materia($1)', [materiaId]))
    expect(await linhas(db, 'select status from public.materias where id = $1', [materiaId])).toEqual([{ status: 'aprovada' }])
  })
})

describe('passo 7: publicação', () => {
  it('editor não publica; admin publica', async () => {
    await expect(como(db, 'editor', () => linhas(db, 'select public.publicar_materia($1)', [materiaId])))
      .rejects.toThrow(/Só o admin/)
    await como(db, 'admin', () => linhas(db, 'select public.publicar_materia($1)', [materiaId]))
  })

  it('leitor anônimo vê a matéria publicada, sem as colunas internas', async () => {
    const r = await como(db, 'anon', () => linhas(db, 'select slug, status from public.materias'))
    expect(r).toEqual([{ slug: 'banco-ajuste-tecnico', status: 'publicada' }])
    await expect(como(db, 'anon', () => linhas(db, 'select alvo_descricao from public.materias')))
      .rejects.toThrow(/permission denied/)
  })

  it('matéria publicada não é editada fora do fluxo de correção', async () => {
    await expect(como(db, 'admin', () => linhas(db, `update public.materias set manchete = 'Nova' where id = $1`, [materiaId])))
      .rejects.toThrow(/fluxo de correção/)
  })
})

describe('kill switch e jurídico', () => {
  it('editor não abre nível 3', async () => {
    await expect(como(db, 'editor', () => linhas(db, `select public.abrir_ocorrencia($1, 3::smallint, 'Acusação indevida')`, [materiaId])))
      .rejects.toThrow(/só do admin/)
  })

  it('nível 2 monitora por 48h', async () => {
    const r = await como(db, 'editor', () => linhas<{ id: number }>(db,
      `select public.abrir_ocorrencia($1, 2::smallint, 'Vários leitores acreditaram') as id`, [materiaId]))
    const o = await linhas<{ horas: number }>(db,
      `select round(extract(epoch from monitorar_ate - aberta_em) / 3600)::int as horas from public.ocorrencias where id = $1`, [r[0]!.id])
    expect(o[0]!.horas).toBe(48)
  })

  it('nível 3 do admin retira a matéria do ar', async () => {
    await como(db, 'admin', () => linhas(db, `select public.abrir_ocorrencia($1, 3::smallint, 'Acusação indevida a pessoa real')`, [materiaId]))
    expect(await linhas(db, 'select status from public.materias where id = $1', [materiaId])).toEqual([{ status: 'retirada' }])
    expect(await como(db, 'anon', () => linhas(db, 'select slug from public.materias'))).toEqual([])
  })

  it('editor não vê notificações jurídicas', async () => {
    await como(db, 'admin', () => linhas(db, `select public.registrar_notificacao(null, 'E-mail de reclamação', 1::smallint)`))
    expect(await como(db, 'editor', () => linhas(db, 'select id from public.notificacoes_juridicas'))).toEqual([])
    expect((await como(db, 'admin', () => linhas(db, 'select id from public.notificacoes_juridicas'))).length).toBe(1)
  })

  it('nível 3 jurídico: 7 dias úteis, pulando o fim de semana', async () => {
    // Sexta, 6 de novembro de 2026, 10h em São Paulo → sexta seguinte (13/11) + 2 dias úteis = terça, 17/11.
    const r = await como(db, 'admin', async () => {
      const [n] = await linhas<{ id: number }>(db,
        `select public.registrar_notificacao(null, 'Ação proposta', 3::smallint, '2026-11-06 10:00-03') as id`)
      return linhas<{ prazo: string }>(db,
        `select to_char(prazo_em at time zone 'America/Sao_Paulo', 'YYYY-MM-DD') as prazo
         from public.notificacoes_juridicas where id = $1`, [n!.id])
    })
    expect(r[0]!.prazo).toBe('2026-11-17')
  })
})

describe('log editorial', () => {
  it('registrou o ciclo de vida inteiro', async () => {
    const r = await linhas<{ acao: string }>(db,
      `select acao from public.log_editorial where entidade = 'materia' and ref = $1 order by numero`, [String(materiaId)])
    expect(r.map(x => x.acao)).toEqual([
      'criada', 'enviada_para_revisao', 'revisor_atribuido', 'revisao_externa_aprovar', 'voltou_para_rascunho',
      'enviada_para_revisao', 'revisao_externa_aprovar', 'aprovada', 'publicada', 'retirada',
    ])
  })

  it('não aceita update nem delete, nem do dono do banco', async () => {
    await expect(linhas(db, `update public.log_editorial set motivo = 'apagado' where numero = 1`)).rejects.toThrow(/só de inserção/)
    await expect(linhas(db, 'delete from public.log_editorial')).rejects.toThrow(/só de inserção/)
  })

  it('a cadeia de hash está íntegra e denuncia adulteração', async () => {
    expect(await linhas(db, 'select public.verificar_log() as quebra')).toEqual([{ quebra: null }])
    // Simula alguém com acesso total desligando a proteção e editando a linha 3.
    await db.exec(`
      alter table public.log_editorial disable trigger log_editorial_sem_update_delete;
      update public.log_editorial set motivo = 'reescrito' where numero = 3;
      alter table public.log_editorial enable trigger log_editorial_sem_update_delete;
    `)
    expect(await linhas(db, 'select public.verificar_log() as quebra')).toEqual([{ quebra: 3 }])
  })
})
