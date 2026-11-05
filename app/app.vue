<script setup lang="ts">
useHead({
  titleTemplate: titulo => (titulo ? `${titulo} · Retórica dos Absurdos` : 'Retórica dos Absurdos'),
})
</script>

<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>
