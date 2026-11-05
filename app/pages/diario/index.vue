<script setup lang="ts">
useSeoMeta({
  title: 'Diário de construção',
  description: 'O Retórica dos Absurdos é construído em público. Cada decisão técnica e de método, registrada.',
})

const { data: posts } = await useAsyncData('diario-lista', () =>
  queryCollection('diario').order('data', 'DESC').all(),
)
</script>

<template>
  <div class="flex flex-col gap-10 max-w-3xl">
    <header class="flex flex-col gap-3">
      <RotuloSecao>Build in public</RotuloSecao>
      <h1 class="font-serif font-extrabold text-4xl md:text-5xl tracking-tight m-0">Diário de construção</h1>
      <p class="font-serif text-lg text-base-content/80 m-0">
        Como o site e o sistema editorial estão sendo construídos, decisão por decisão. O código é aberto; as pautas, não.
      </p>
      <a href="https://github.com/mlucascosta/retorica-dos-absurdos" class="text-sm font-semibold self-start" rel="noopener">Ver o código no GitHub</a>
    </header>

    <ul class="flex flex-col divide-y divide-base-300 border-y border-base-300">
      <li v-for="p in posts" :key="p.path" class="py-5">
        <NuxtLink :to="p.path" class="no-underline text-base-content flex flex-col gap-1 hover:text-link">
          <span class="font-mono text-xs text-base-content/70">{{ p.data }}{{ p.marco ? ` · ${p.marco}` : '' }}</span>
          <span class="font-serif font-bold text-2xl">{{ p.title }}</span>
          <span class="text-base-content/80">{{ p.resumo }}</span>
        </NuxtLink>
      </li>
    </ul>
  </div>
</template>
