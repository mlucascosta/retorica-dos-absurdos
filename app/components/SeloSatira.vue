<script setup lang="ts">
withDefaults(defineProps<{ texto?: string }>(), { texto: 'SÁTIRA' })
</script>

<template>
  <span class="inline-block bg-primary text-primary-content text-[10px] font-bold tracking-[.16em] px-2 py-1 rounded-md leading-none">{{ texto }}</span>
</template>
