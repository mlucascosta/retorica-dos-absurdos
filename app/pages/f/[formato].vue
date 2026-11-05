<script setup lang="ts">
const route = useRoute()
const formato = formatoPorSlug(String(route.params.formato))
if (!formato) {
  throw createError({ statusCode: 404, statusMessage: 'Formato não encontrado', fatal: true })
}
useSeoMeta({ title: formato.nome, description: formato.descricao })
</script>

<template>
  <div v-if="formato" class="flex flex-col gap-10">
    <header class="flex flex-col gap-3 max-w-3xl">
      <RotuloSecao>Formato {{ String(formato.numero).padStart(2, '0') }} de 08</RotuloSecao>
      <h1 class="font-serif font-extrabold text-4xl md:text-5xl tracking-tight m-0">{{ formato.nome }}</h1>
      <p class="font-serif text-lg text-base-content/80 m-0">{{ formato.descricao }}</p>
    </header>

    <section v-if="formato.tarja" class="flex flex-col gap-3 max-w-3xl">
      <TarjaFormato :texto="formato.tarja" />
      <p class="text-sm text-base-content/80 m-0">
        Toda publicação deste formato leva esta tarja no topo do texto e em cada card compartilhável.
        Nomes de órgãos e institutos são sempre manifestamente fictícios.
      </p>
    </section>

    <section class="rounded-box border border-dashed border-base-300 p-8 text-center flex flex-col gap-2 items-center">
      <Icon name="ion:file-tray-outline" class="text-3xl text-base-content/70" />
      <p class="font-serif text-lg m-0">Nenhuma matéria publicada neste formato ainda.</p>
    </section>

    <NuxtLink to="/f" class="text-sm font-semibold self-start">Todos os formatos</NuxtLink>
  </div>
</template>
