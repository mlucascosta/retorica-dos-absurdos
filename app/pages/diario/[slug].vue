<script setup lang="ts">
const route = useRoute()
const { data: post } = await useAsyncData(`diario-${route.path}`, () =>
  queryCollection('diario').path(route.path).first(),
)
if (!post.value) {
  throw createError({ statusCode: 404, statusMessage: 'Post não encontrado', fatal: true })
}
useSeoMeta({
  title: post.value.title,
  description: post.value.resumo,
  ogType: 'article',
})
</script>

<template>
  <article v-if="post" class="flex flex-col gap-6 max-w-3xl mx-auto">
    <NuxtLink to="/diario" class="text-sm font-semibold self-start">Diário de construção</NuxtLink>
    <header class="flex flex-col gap-3">
      <span class="font-mono text-xs text-base-content/70">{{ post.data }}{{ post.marco ? ` · ${post.marco}` : '' }}</span>
      <h1 class="font-serif font-extrabold text-4xl md:text-5xl leading-[1.08] tracking-tight m-0">{{ post.title }}</h1>
      <p class="font-serif italic text-lg text-base-content/80 m-0">{{ post.resumo }}</p>
    </header>
    <ContentRenderer :value="post" class="prosa" />
  </article>
</template>
