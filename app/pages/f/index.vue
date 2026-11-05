<script setup lang="ts">
useSeoMeta({
  title: 'Formatos',
  description: 'Oito formatos de absurdo. O formato muda o tom; a identidade permanece.',
})
</script>

<template>
  <div class="flex flex-col gap-10">
    <header class="flex flex-col gap-3 max-w-3xl">
      <h1 class="font-serif font-extrabold text-4xl md:text-5xl tracking-tight m-0">Oito formatos de absurdo</h1>
      <p class="font-serif text-lg text-base-content/80 m-0">
        O mesmo absurdo pode virar notícia, documento, pesquisa, entrevista ou lista. O formato muda o tom; a identidade permanece.
      </p>
    </header>
    <ul class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <li v-for="f in formatos" :key="f.slug">
        <NuxtLink :to="`/f/${f.slug}`" class="h-full rounded-box border border-base-300 p-5 flex flex-col gap-2 no-underline text-base-content hover:bg-base-200">
          <span class="font-mono text-xs text-base-content/70">FORMATO {{ String(f.numero).padStart(2, '0') }}</span>
          <span class="font-serif font-bold text-lg">{{ f.nome }}</span>
          <span class="text-sm text-base-content/80 leading-snug">{{ f.descricao }}</span>
        </NuxtLink>
      </li>
    </ul>
  </div>
</template>
