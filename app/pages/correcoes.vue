<script setup lang="ts">
useSeoMeta({
  title: 'Correções',
  description: 'Política de correções e registro público de correções do Retórica dos Absurdos.',
})
const { recursos } = useAppConfig()
</script>

<template>
  <div class="flex flex-col gap-10 max-w-4xl">
    <header class="flex flex-col gap-3">
      <h1 class="font-serif font-extrabold text-4xl md:text-5xl tracking-tight m-0">Correções</h1>
      <p class="font-serif text-lg text-base-content/80 m-0">
        Sátira séria tem protocolo de erro. Quando erramos um fato de origem, corrigimos no texto, registramos aqui e
        avisamos nos canais onde a matéria circulou.
      </p>
      <NuxtLink v-if="recursos.contato" to="/contato?assunto=correcao" class="btn btn-primary rounded-full self-start">Solicitar correção</NuxtLink>
    </header>

    <section class="prosa">
      <h2>Como corrigimos</h2>
      <ol>
        <li>Identificamos a informação incorreta.</li>
        <li>Verificamos sua origem.</li>
        <li>Corrigimos o conteúdo.</li>
        <li>Registramos a alteração nesta página quando for relevante.</li>
        <li>Publicamos esclarecimento se o erro já tiver circulado significativamente.</li>
        <li>Retiramos a publicação quando não for possível corrigir adequadamente.</li>
      </ol>
      <p>Não apagamos silenciosamente um erro relevante. Uma matéria retirada continua com endereço próprio, informando a data e o motivo.</p>
    </section>

    <section class="flex flex-col gap-3" aria-labelledby="titulo-registro">
      <h2 id="titulo-registro" class="font-serif font-extrabold text-2xl m-0">Registro público</h2>
      <div class="overflow-x-auto rounded-box border border-base-300">
        <table class="table">
          <thead>
            <tr>
              <th>Data</th>
              <th>Matéria</th>
              <th>O que estava errado</th>
              <th>Correção</th>
              <th>Tipo</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td colspan="5" class="text-center text-base-content/70 py-8">Nenhuma correção registrada até agora. Nenhuma matéria foi publicada ainda, o que ajuda.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>
