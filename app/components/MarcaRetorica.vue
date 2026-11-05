<script setup lang="ts">
withDefaults(defineProps<{ tamanho?: 'sm' | 'md' | 'lg' }>(), { tamanho: 'lg' })
</script>

<template>
  <span
    class="font-serif font-extrabold leading-none tracking-tight text-base-content"
    :class="{
      'text-[19px]': tamanho === 'sm',
      'text-[28px]': tamanho === 'md',
      'text-[32px] md:text-[40px]': tamanho === 'lg',
    }"
  >Retórica <span class="italic font-semibold text-primary">dos</span> Absurdos</span>
</template>
