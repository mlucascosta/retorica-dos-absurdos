import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { describe, expect, it } from 'vitest'

// Recalcula o contraste do tema a cada PR (WCAG 2.2 AA).
// Se alguém mudar uma cor do contrato visual e quebrar a legibilidade, o CI falha.

const css = readFileSync(fileURLToPath(new URL('../app/assets/css/theme.css', import.meta.url)), 'utf8')

function cor(nome: string): string {
  const achado = css.match(new RegExp(`--${nome}:\\s*(#[0-9a-fA-F]{6})`))
  if (!achado?.[1]) throw new Error(`Cor --${nome} não encontrada em theme.css`)
  return achado[1]
}

function luminancia(hex: string): number {
  const canais = [1, 3, 5].map((i) => {
    const c = Number.parseInt(hex.slice(i, i + 2), 16) / 255
    return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4
  })
  return 0.2126 * canais[0]! + 0.7152 * canais[1]! + 0.0722 * canais[2]!
}

function contraste(a: string, b: string): number {
  const [claro, escuro] = [luminancia(a), luminancia(b)].sort((x, y) => y - x)
  return (claro! + 0.05) / (escuro! + 0.05)
}

const TEXTO_NORMAL = 4.5

describe('contrato visual: contraste do tema retorica', () => {
  const pares = ['primary', 'secondary', 'accent', 'neutral', 'info', 'success', 'warning', 'error']

  it.each(pares)('texto sobre %s passa no AA', (nome) => {
    const valor = contraste(cor(`color-${nome}`), cor(`color-${nome}-content`))
    expect(valor, `${nome}: ${valor.toFixed(2)}`).toBeGreaterThanOrEqual(TEXTO_NORMAL)
  })

  it('texto base passa no AA sobre os três fundos', () => {
    for (const fundo of ['base-100', 'base-200', 'base-300']) {
      expect(contraste(cor('color-base-content'), cor(`color-${fundo}`))).toBeGreaterThanOrEqual(TEXTO_NORMAL)
    }
  })

  it('link passa no AA sobre o fundo branco', () => {
    expect(contraste(cor('color-link'), cor('color-base-100'))).toBeGreaterThanOrEqual(TEXTO_NORMAL)
  })

  it('selo SÁTIRA (texto branco sobre primary) passa no AA', () => {
    expect(contraste('#ffffff', cor('color-primary'))).toBeGreaterThanOrEqual(TEXTO_NORMAL)
  })
})
