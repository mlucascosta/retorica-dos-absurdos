<script setup lang="ts">
const { recursos, canais } = useAppConfig()
const ano = 2026
</script>

<template>
  <footer class="w-full bg-base-200 border-t border-base-300 px-4 md:px-10 pt-12 pb-7 flex flex-col gap-9">
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-[1.6fr_1fr_1fr_1fr] gap-10">
      <div class="flex flex-col gap-3">
        <MarcaRetorica tamanho="md" />
        <p class="m-0 text-sm leading-relaxed text-base-content/80 max-w-sm">{{ avisoEditorialPadrao }}</p>
        <div class="flex gap-2 mt-1">
          <a v-if="canais.telegram" :href="canais.telegram" class="btn btn-circle btn-sm btn-ghost border-base-300" aria-label="Telegram" rel="noopener"><Icon name="ion:paper-plane-outline" /></a>
          <a v-if="canais.instagram" :href="canais.instagram" class="btn btn-circle btn-sm btn-ghost border-base-300" aria-label="Instagram" rel="noopener"><Icon name="ion:logo-instagram" /></a>
          <NuxtLink v-if="recursos.newsletter" to="/newsletter" class="btn btn-circle btn-sm btn-ghost border-base-300" aria-label="Newsletter"><Icon name="ion:mail-outline" /></NuxtLink>
          <a href="https://github.com/mlucascosta/retorica-dos-absurdos" class="btn btn-circle btn-sm btn-ghost border-base-300 text-base-content" aria-label="Código-fonte no GitHub" rel="noopener"><Icon name="ion:logo-github" /></a>
        </div>
      </div>

      <nav class="flex flex-col gap-2 text-sm" aria-label="Territórios">
        <span class="text-xs font-bold tracking-widest uppercase text-base-content/70 mb-1">Territórios</span>
        <NuxtLink v-for="t in territorios" :key="t.slug" :to="`/t/${t.slug}`" class="text-base-content no-underline hover:underline">{{ t.nome }}</NuxtLink>
      </nav>

      <nav class="flex flex-col gap-2 text-sm" aria-label="O projeto">
        <span class="text-xs font-bold tracking-widest uppercase text-base-content/70 mb-1">O projeto</span>
        <NuxtLink to="/sobre" class="text-base-content no-underline hover:underline">Sobre e manifesto</NuxtLink>
        <NuxtLink to="/politica-editorial" class="text-base-content no-underline hover:underline">Política editorial</NuxtLink>
        <NuxtLink to="/correcoes" class="text-base-content no-underline hover:underline">Política de correções</NuxtLink>
        <NuxtLink to="/aviso-de-satira" class="text-base-content no-underline hover:underline">Identificação de sátira</NuxtLink>
        <NuxtLink to="/diario" class="text-base-content no-underline hover:underline">Diário de construção</NuxtLink>
        <NuxtLink v-if="recursos.contato" to="/contato" class="text-base-content no-underline hover:underline">Contato</NuxtLink>
      </nav>

      <nav class="flex flex-col gap-2 text-sm" aria-label="Legal">
        <span class="text-xs font-bold tracking-widest uppercase text-base-content/70 mb-1">Legal</span>
        <NuxtLink to="/privacidade" class="text-base-content no-underline hover:underline">Privacidade (LGPD)</NuxtLink>
        <NuxtLink v-if="recursos.anuncios" to="/publicidade" class="text-base-content no-underline hover:underline">Publicidade</NuxtLink>
      </nav>
    </div>

    <div class="flex flex-col sm:flex-row gap-2 justify-between border-t border-base-300 pt-4 text-[13px] text-base-content/70">
      <span>© {{ ano }} Retórica dos Absurdos · Publicação independente</span>
      <span class="font-serif italic">O seu jornal isento de profissionalismo e seriedade</span>
    </div>
  </footer>
</template>
