/**
 * Recursos do design que entram em marcos posteriores.
 * Enquanto estiver `false`, o recurso não aparece no menu nem gera link,
 * para o site nunca apontar para uma página que ainda não existe.
 */
export default defineAppConfig({
  recursos: {
    busca: false, // M3
    newsletter: false, // M3, depende de /privacidade e provedor de e-mail
    contato: false, // M3, depende do formulário com limite de taxa no banco
    investigacoes: false, // depois da Fase 0 jurídica
    absurdometro: false, // depois de M4, com governança do agente
    anuncios: false, // depois da aprovação no AdSense e do CMP
    audio: false, // M3+, Piper TTS
  },
  canais: {
    telegram: '', // preencher quando o canal existir
    instagram: '',
  },
})
