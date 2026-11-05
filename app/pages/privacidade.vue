<script setup lang="ts">
useSeoMeta({
  title: 'Privacidade',
  description: 'Que dados o Retórica dos Absurdos trata, por quê e por quanto tempo.',
})
</script>

<template>
  <article class="flex flex-col gap-6 max-w-3xl">
    <h1 class="font-serif font-extrabold text-4xl md:text-5xl tracking-tight m-0">Privacidade</h1>
    <p class="font-mono text-xs text-base-content/70 m-0">Versão 0.1 · em vigor desde 5 de novembro de 2026</p>
    <div class="prosa">
      <p>
        Esta página descreve o que o site faz hoje. Ela será atualizada, com data, antes de qualquer recurso que colete
        dados pessoais entrar no ar.
      </p>
      <h2>O que coletamos hoje</h2>
      <p>
        Nada que identifique você. O site não tem cadastro, comentários, formulários, newsletter, cookies de
        rastreamento nem anúncios. Fontes e ícones são servidos pelo próprio site, sem chamadas ao Google ou a
        outros terceiros.
      </p>
      <p>
        A hospedagem (Vercel) registra dados técnicos de acesso, como endereço IP e navegador, para segurança e
        funcionamento do serviço. Não usamos esses registros para identificar leitores.
      </p>
      <h2>O que vai mudar, e quando</h2>
      <p>
        Formulário de contato e newsletter estão previstos. Antes de entrarem no ar, esta página dirá quais dados
        serão tratados, com qual base legal da LGPD (consentimento para a newsletter, legítimo interesse para responder
        mensagens), por quanto tempo serão guardados e como pedir a exclusão.
      </p>
    </div>
  </article>
</template>
