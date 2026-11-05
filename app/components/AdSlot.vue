<script setup lang="ts">
// Espaço de anúncio do design (AdSlot). Fica desligado até a aprovação no AdSense,
// o CMP de consentimento e as páginas legais estarem no ar (app.config: recursos.anuncios).
// Nunca dentro da manchete, nunca imitando matéria, sempre rotulado "Publicidade".
withDefaults(defineProps<{ rotulo?: string, tamanho?: string }>(), {
  rotulo: 'AdSense · display',
  tamanho: '',
})
const { recursos } = useAppConfig()
</script>

<template>
  <aside v-if="recursos.anuncios" class="w-full h-full flex flex-col gap-1" aria-label="Publicidade">
    <span class="text-[10px] font-semibold tracking-[.18em] uppercase text-base-content/70">Publicidade</span>
    <div class="flex-1 min-h-0 rounded-xl border border-dashed border-[#c4c4c4] bg-[repeating-linear-gradient(135deg,#f2f2f2_0_8px,#fafafa_8px_16px)] flex flex-col items-center justify-center gap-1 text-base-content/70">
      <span class="flex items-center gap-1.5 font-mono text-xs"><Icon name="ion:megaphone-outline" />{{ rotulo }}</span>
      <span class="font-mono text-[11px]">{{ tamanho }}</span>
    </div>
  </aside>
</template>
