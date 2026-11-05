<script setup lang="ts">
import type { NuxtError } from '#app'

const props = defineProps<{ error: NuxtError }>()
const naoEncontrada = computed(() => props.error.statusCode === 404)

useSeoMeta({
  title: naoEncontrada.value ? 'Página não encontrada' : 'Erro',
  robots: 'noindex',
})

function voltar() {
  clearError({ redirect: '/' })
}
</script>

<template>
  <NuxtLayout>
    <div class="max-w-2xl mx-auto flex flex-col gap-6">
      <template v-if="naoEncontrada">
        <TarjaFormato texto="DOCUMENTO FICTÍCIO — SÁTIRA" />
        <div class="rounded-box border border-base-300 p-6 md:p-10 flex flex-col gap-4 font-serif">
          <span class="font-mono text-xs tracking-widest text-base-content/70">OFÍCIO Nº 404/2026 — COORDENAÇÃO DE PÁGINAS INEXISTENTES</span>
          <h1 class="font-extrabold text-3xl leading-tight m-0">
            A página solicitada foi encaminhada à comissão responsável por localizar páginas.
          </h1>
          <p class="text-lg m-0">Prazo estimado de resposta: indeterminado, prorrogável.</p>
          <p class="text-sm font-sans text-base-content/70 m-0">
            AVISO: ficção satírica. A coordenação citada não existe. A página que você procurou, aparentemente, também não.
          </p>
        </div>
      </template>
      <template v-else>
        <h1 class="font-serif font-extrabold text-3xl m-0">Algo deu errado do nosso lado.</h1>
        <p class="m-0 text-base-content/80">Erro {{ error.statusCode }}. Desta vez não é sátira.</p>
      </template>
      <button class="btn btn-primary rounded-full self-start" @click="voltar">Voltar ao início</button>
    </div>
  </NuxtLayout>
</template>
