import tailwindcss from '@tailwindcss/vite'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2026-11-01',
  devtools: { enabled: false },

  modules: ['@nuxt/eslint', '@nuxt/content', '@nuxt/icon', 'nuxt-security'],

  css: ['~/assets/css/main.css'],

  // O Node 26 traz SQLite embutido (node:sqlite): sem módulo nativo para compilar.
  content: {
    experimental: { sqliteConnector: 'native' },
  },

  vite: {
    plugins: [tailwindcss()],
  },

  app: {
    head: {
      htmlAttrs: { 'lang': 'pt-BR', 'data-theme': 'retorica' },
      meta: [
        { name: 'description', content: 'Publicação brasileira de sátira. A realidade não precisa de nossa ajuda para ser absurda.' },
        { name: 'theme-color', content: '#ffffff' },
        { property: 'og:site_name', content: 'Retórica dos Absurdos' },
        { property: 'og:locale', content: 'pt_BR' },
      ],
      link: [{ rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' }],
    },
  },

  // Ícones Ionicons empacotados no próprio site: nenhuma requisição a CDN.
  icon: {
    mode: 'css',
    provider: 'none',
    fallbackToApi: false,
    serverBundle: 'local',
    // Ícones com nome dinâmico não são achados pela varredura; ficam listados aqui.
    clientBundle: { scan: true, includeCustomCollections: true, icons: ['ion:menu-outline', 'ion:close-outline'] },
  },

  routeRules: {
    // Área administrativa (M2): sem SSR, sem indexação.
    '/admin/**': {
      ssr: false,
      headers: { 'X-Robots-Tag': 'noindex, nofollow' },
    },
  },

  nitro: {
    preset: 'vercel',
    // Funções em São Paulo, perto do Supabase (sa-east-1).
    vercel: { functions: { regions: ['gru1'] } },
    prerender: {
      crawlLinks: true,
      routes: ['/'],
      failOnError: true,
    },
  },

  security: {
    headers: {
      contentSecurityPolicy: {
        'default-src': ["'self'"],
        'base-uri': ["'none'"],
        'font-src': ["'self'"],
        'img-src': ["'self'", 'data:'],
        'style-src': ["'self'", "'unsafe-inline'"],
        'script-src': ["'self'", "'strict-dynamic'", "'nonce-{{nonce}}'", "'wasm-unsafe-eval'"],
        'connect-src': ["'self'"],
        'form-action': ["'self'"],
        'frame-ancestors': ["'none'"],
        'object-src': ["'none'"],
        'upgrade-insecure-requests': true,
      },
      strictTransportSecurity: { maxAge: 63072000, includeSubdomains: true, preload: true },
      xFrameOptions: 'DENY',
      referrerPolicy: 'strict-origin-when-cross-origin',
      permissionsPolicy: {
        'camera': [],
        'microphone': [],
        'geolocation': [],
        'display-capture': [],
        'fullscreen': [],
      },
      crossOriginEmbedderPolicy: false,
    },
    // Limite de taxa em memória não funciona em funções serverless;
    // os formulários públicos (M3) terão limite no banco.
    rateLimiter: false,
  },

  typescript: {
    strict: true,
  },
})
