<script setup lang="ts">
useSeoMeta({
  title: 'Sobre e manifesto',
  description: 'O manifesto editorial e as doze regras do Retórica dos Absurdos.',
})
</script>

<template>
  <div class="grid lg:grid-cols-[1.4fr_1fr] gap-12">
    <article class="flex flex-col gap-6">
      <RotuloSecao>Manifesto editorial</RotuloSecao>
      <h1 class="font-serif font-extrabold text-4xl md:text-5xl leading-[1.08] tracking-tight m-0">
        Não acreditamos que o absurdo precise ser inventado.
      </h1>
      <div class="prosa">
        <p>
          Ele aparece nos discursos cuidadosamente preparados, nas decisões tomadas em nome do bom senso, nos
          procedimentos que resolvem problemas criando outros, nas promessas que sobrevivem à própria realidade e nos
          comportamentos que todos reconhecem, mas poucos admitem.
        </p>
        <p><strong>Estamos aqui para observar.</strong></p>
        <p>
          Não temos compromisso com a solenidade de quem se leva excessivamente a sério. Não temos obrigação de tratar
          o poder como algo intocável. Não precisamos transformar toda contradição em um tratado acadêmico.
        </p>
        <p>Preferimos a ironia à reverência, a inteligência ao insulto e a precisão ao exagero gratuito.</p>
        <p>
          Podemos falar de política, economia, tecnologia, cultura, empresas, celebridades, esportes, cotidiano e
          qualquer outra coisa que mereça uma boa observação.
        </p>
        <p>Nossa matéria-prima é a realidade. Nossa ferramenta é o humor.</p>
        <p>
          Acreditamos que uma boa sátira não precisa gritar que é engraçada. Ela apresenta a situação, desenvolve a
          lógica e deixa o leitor chegar à conclusão.
        </p>
        <p>
          Não somos imparciais diante da hipocrisia, da estupidez deliberada e do abuso de poder. Mas também não somos
          uma publicação a serviço de uma facção.
        </p>
        <p>Não inventamos fatos para sustentar piadas. Não sacrificamos a credibilidade por uma manchete. Não publicamos por obrigação.</p>
        <p>E, principalmente, não temos a pretensão de estar acima daquilo que criticamos.</p>
        <p class="font-serif italic text-xl">{{ lema }}</p>

        <h2>O que somos</h2>
        <ul>
          <li>Uma publicação de sátira brasileira.</li>
          <li>Um observatório humorístico das contradições da realidade.</li>
          <li>Um projeto de crítica social que utiliza o humor como linguagem.</li>
          <li>Uma publicação irreverente, independente e editorialmente consistente.</li>
        </ul>
        <h2>O que não somos</h2>
        <ul>
          <li>Um portal convencional de notícias.</li>
          <li>Um agregador de memes.</li>
          <li>Uma página exclusivamente política.</li>
          <li>Uma publicação partidária.</li>
          <li>Uma fábrica de manchetes inventadas sem propósito.</li>
          <li>Um veículo que apresenta conteúdo fictício como informação verdadeira.</li>
        </ul>
      </div>
    </article>

    <aside class="flex flex-col gap-4 self-start lg:sticky lg:top-6">
      <h2 class="font-serif font-extrabold text-2xl m-0">As doze regras</h2>
      <ol class="flex flex-col divide-y divide-base-300 border-y border-base-300">
        <li v-for="(regra, i) in dozeRegras" :key="i" class="flex gap-4 py-3">
          <span class="font-mono text-sm text-primary font-semibold w-6 shrink-0">{{ String(i + 1).padStart(2, '0') }}</span>
          <span class="font-serif">{{ regra }}</span>
        </li>
      </ol>
    </aside>
  </div>
</template>
