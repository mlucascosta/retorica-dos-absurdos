<script setup lang="ts">
const route = useRoute()
const slug = String(route.params.territorio)
const territorio = territorioPorSlug(slug)
if (!territorio) {
  throw createError({ statusCode: 404, statusMessage: 'Território não encontrado', fatal: true })
}
const indice = territorios.findIndex(t => t.slug === slug) + 1
const outros = territorios.filter(t => t.slug !== slug)

useSeoMeta({ title: territorio.nome, description: territorio.descricao })
</script>

<template>
  <div v-if="territorio" class="flex flex-col gap-10">
    <header class="flex flex-col gap-3 max-w-3xl">
      <RotuloSecao>Território {{ indice }} de {{ territorios.length }}</RotuloSecao>
      <h1 class="font-serif font-extrabold text-4xl md:text-5xl tracking-tight m-0">{{ territorio.nome }}</h1>
      <p class="font-serif text-lg text-base-content/80 m-0">{{ territorio.descricao }}</p>
    </header>

    <section class="rounded-box border border-dashed border-base-300 p-8 text-center flex flex-col gap-2 items-center">
      <Icon name="ion:file-tray-outline" class="text-3xl text-base-content/70" />
      <p class="font-serif text-lg m-0">Nenhuma matéria publicada neste território ainda.</p>
      <p class="text-sm text-base-content/70 m-0 max-w-md">Regra 9: a qualidade prevalece sobre a frequência. Quando não houver absurdo bom, não publicamos.</p>
    </section>

    <nav class="flex flex-col gap-3" aria-label="Outros territórios">
      <RotuloSecao>Outros territórios</RotuloSecao>
      <ul class="flex flex-wrap gap-2">
        <li v-for="t in outros" :key="t.slug">
          <NuxtLink :to="`/t/${t.slug}`" class="btn btn-sm rounded-full btn-ghost border-base-300">{{ t.nome }}</NuxtLink>
        </li>
      </ul>
    </nav>
  </div>
</template>
