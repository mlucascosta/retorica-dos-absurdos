<script setup lang="ts">
useSeoMeta({
  title: 'Identificação de sátira',
  description: 'Como reconhecer o conteúdo satírico do Retórica dos Absurdos: selo, tarjas e categorias.',
})

const marcas = [
  { marca: 'SÁTIRA', titulo: 'Em toda matéria e card', texto: 'O selo aparece no topo do texto e em todo card compartilhável, dentro da própria imagem.' },
  { marca: 'DOCUMENTO FICTÍCIO', titulo: 'Documentos parodiados', texto: 'Tarja obrigatória acima de portarias, decretos e editais inventados, sempre emitidos por órgãos que não existem.' },
  { marca: 'PESQUISA INVENTADA', titulo: 'Pesquisas parodiadas', texto: 'Marca acima de cada número, no texto e nos cards. Institutos citados são inexistentes.' },
  { marca: 'CAT. A · B · C', titulo: 'Categoria editorial', texto: 'Indica se partimos de um fato real (A), de ficção (B) ou de observação (C).' },
]
</script>

<template>
  <div class="flex flex-col gap-10 max-w-4xl">
    <header class="flex flex-col gap-4">
      <SeloSatira />
      <h1 class="font-serif font-extrabold text-4xl md:text-5xl tracking-tight m-0">Isto é sátira. Veja como reconhecer.</h1>
      <p class="font-serif text-lg text-base-content/80 m-0">{{ avisoEditorialPadrao }}</p>
    </header>

    <ul class="grid sm:grid-cols-2 gap-4">
      <li v-for="m in marcas" :key="m.marca" class="rounded-box border border-base-300 p-5 flex flex-col gap-3">
        <SeloSatira :texto="m.marca" class="self-start" />
        <span class="font-serif font-bold text-lg">{{ m.titulo }}</span>
        <span class="text-sm text-base-content/80 leading-snug">{{ m.texto }}</span>
      </li>
    </ul>

    <section class="rounded-box bg-base-200 p-6 flex flex-col gap-2">
      <h2 class="font-serif font-extrabold text-xl m-0">Achou que uma matéria era notícia real?</h2>
      <p class="m-0 text-base-content/80">
        Isso aciona nosso protocolo de esclarecimento: respondemos, reforçamos a identificação e, se a confusão se
        espalhar, publicamos um esclarecimento ou retiramos a matéria.
      </p>
    </section>
  </div>
</template>
