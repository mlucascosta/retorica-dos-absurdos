<script setup lang="ts">
// Tarja obrigatória dos formatos 2 (DOCUMENTO FICTÍCIO — SÁTIRA) e 3 (PESQUISA INVENTADA).
defineProps<{ texto: string }>()
</script>

<template>
  <div
    class="w-full bg-neutral text-neutral-content text-center font-mono text-xs font-semibold tracking-[.18em] uppercase py-2 px-3 rounded-lg"
    role="note"
  >
    {{ texto }}
  </div>
</template>
