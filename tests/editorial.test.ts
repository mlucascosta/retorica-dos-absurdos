import { describe, expect, it } from 'vitest'
import { dozeRegras, formatoPorSlug, formatos, territorios } from '../app/utils/editorial'

describe('taxonomias do manual', () => {
  it('tem 5 territórios, 8 formatos e 12 regras', () => {
    expect(territorios).toHaveLength(5)
    expect(formatos).toHaveLength(8)
    expect(dozeRegras).toHaveLength(12)
  })

  it('slugs são únicos', () => {
    expect(new Set(territorios.map(t => t.slug)).size).toBe(territorios.length)
    expect(new Set(formatos.map(f => f.slug)).size).toBe(formatos.length)
  })

  it('documentos e pesquisas carregam a tarja obrigatória do addendum v1.1', () => {
    expect(formatoPorSlug('documentos-e-instituicoes')?.tarja).toBe('DOCUMENTO FICTÍCIO — SÁTIRA')
    expect(formatoPorSlug('pesquisas-e-levantamentos')?.tarja).toBe('PESQUISA INVENTADA')
  })
})
