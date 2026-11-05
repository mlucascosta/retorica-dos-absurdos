<template>
  <div class="min-h-dvh flex flex-col bg-base-100">
    <a href="#conteudo" class="sr-only focus:not-sr-only focus:absolute focus:top-2 focus:left-2 focus:z-50 btn btn-sm">Pular para o conteúdo</a>
    <PublicHeader />
    <main id="conteudo" class="flex-1 w-full max-w-[1200px] mx-auto px-4 md:px-10 py-8 md:py-12">
      <slot />
    </main>
    <PublicFooter />
  </div>
</template>
