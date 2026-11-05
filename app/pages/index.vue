<script setup lang="ts">
useSeoMeta({
  title: undefined,
  ogTitle: 'Retórica dos Absurdos',
  description: lema,
})

const { data: posts } = await useAsyncData('diario-home', () =>
  queryCollection('diario').order('data', 'DESC').limit(3).all(),
)
</script>

<template>
  <div class="flex flex-col gap-14">
    <section class="grid lg:grid-cols-[1.4fr_1fr] gap-8 items-stretch">
      <article class="rounded-box border border-base-300 p-6 md:p-10 flex flex-col gap-4 justify-center bg-base-100">
        <div class="flex items-center gap-2 flex-wrap">
          <SeloSatira />
          <RotuloSecao>Comunicado da redação · fase de fundação</RotuloSecao>
        </div>
        <h1 class="font-serif font-extrabold text-3xl md:text-[44px] leading-[1.08] tracking-tight m-0">
          Redação anuncia que publicará absurdos assim que terminar de construir o lugar onde vai publicá-los
        </h1>
        <p class="font-serif italic text-lg text-base-content/80 m-0">
          Prazo foi descrito como "breve, de natureza não vinculante e sujeito à qualidade das pautas".
        </p>
        <p class="m-0 text-base-content/80 leading-relaxed">
          O site está sendo construído em público. Enquanto as primeiras matérias passam pelo controle editorial,
          dá para acompanhar cada decisão no diário de construção.
        </p>
        <div class="flex gap-2 flex-wrap mt-2">
          <NuxtLink to="/diario" class="btn btn-primary rounded-full">Ler o diário</NuxtLink>
          <NuxtLink to="/sobre" class="btn btn-ghost rounded-full border-base-300">Manifesto</NuxtLink>
        </div>
      </article>

      <aside class="rounded-box bg-neutral text-neutral-content p-6 md:p-8 flex flex-col gap-3">
        <RotuloSecao><span class="text-neutral-content/80">Formato 8</span></RotuloSecao>
        <h2 class="font-serif font-extrabold text-2xl m-0">A realidade supera a sátira</h2>
        <p class="m-0 text-neutral-content/85 leading-relaxed">
          Fatos reais, documentados e arquivados, publicados sem nenhuma alteração. Nenhuma piada foi necessária.
        </p>
        <span class="font-mono text-xs text-neutral-content/80 mt-auto">fonte primária · link original · captura arquivada</span>
      </aside>
    </section>

    <section class="flex flex-col gap-5" aria-labelledby="titulo-territorios">
      <h2 id="titulo-territorios" class="font-serif font-extrabold text-2xl m-0">Territórios</h2>
      <ul class="grid sm:grid-cols-2 lg:grid-cols-5 gap-4">
        <li v-for="t in territorios" :key="t.slug">
          <NuxtLink :to="`/t/${t.slug}`" class="h-full rounded-box border border-base-300 p-5 flex flex-col gap-2 no-underline text-base-content hover:bg-base-200">
            <span class="font-serif font-bold text-lg">{{ t.nome }}</span>
            <span class="text-sm text-base-content/70 leading-snug">{{ t.descricao }}</span>
          </NuxtLink>
        </li>
      </ul>
    </section>

    <section class="flex flex-col gap-5" aria-labelledby="titulo-formatos">
      <div class="flex items-baseline justify-between gap-4">
        <h2 id="titulo-formatos" class="font-serif font-extrabold text-2xl m-0">Formatos</h2>
        <NuxtLink to="/f" class="text-sm font-semibold">Ver os oito</NuxtLink>
      </div>
      <ul class="flex flex-wrap gap-2">
        <li v-for="f in formatos" :key="f.slug">
          <NuxtLink :to="`/f/${f.slug}`" class="btn btn-sm rounded-full btn-ghost border-base-300 font-semibold">
            <span class="font-mono text-xs text-base-content/70">{{ String(f.numero).padStart(2, '0') }}</span>{{ f.nome }}
          </NuxtLink>
        </li>
      </ul>
    </section>

    <section class="grid lg:grid-cols-[1.4fr_1fr] gap-8" aria-labelledby="titulo-diario">
      <div class="flex flex-col gap-4">
        <h2 id="titulo-diario" class="font-serif font-extrabold text-2xl m-0">Diário de construção</h2>
        <ul v-if="posts?.length" class="flex flex-col divide-y divide-base-300 border-y border-base-300">
          <li v-for="p in posts" :key="p.path" class="py-4">
            <NuxtLink :to="p.path" class="no-underline text-base-content flex flex-col gap-1 hover:text-link">
              <span class="font-mono text-xs text-base-content/70">{{ p.data }}{{ p.marco ? ` · ${p.marco}` : '' }}</span>
              <span class="font-serif font-bold text-xl">{{ p.title }}</span>
              <span class="text-sm text-base-content/80">{{ p.resumo }}</span>
            </NuxtLink>
          </li>
        </ul>
      </div>
      <aside class="rounded-box bg-base-200 p-6 flex flex-col gap-3 self-start">
        <SeloSatira class="self-start" />
        <h2 class="font-serif font-extrabold text-xl m-0">Como reconhecer nossa sátira</h2>
        <p class="m-0 text-sm text-base-content/80 leading-relaxed">
          Selo em toda matéria e todo card, tarja nos documentos e pesquisas inventados, categoria A, B ou C em cada texto.
        </p>
        <NuxtLink to="/aviso-de-satira" class="text-sm font-semibold">Ver a identificação de sátira</NuxtLink>
      </aside>
    </section>
  </div>
</template>
