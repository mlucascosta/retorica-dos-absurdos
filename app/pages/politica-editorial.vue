<script setup lang="ts">
useSeoMeta({
  title: 'Política editorial',
  description: 'Categorias A, B e C, limites editoriais, fontes, uso de inteligência artificial e aprovação.',
})

const secoes = [
  { id: 'fatos-ficcao', titulo: 'Fatos, ficção e transparência' },
  { id: 'limites', titulo: 'Limites editoriais' },
  { id: 'fontes', titulo: 'Fontes' },
  { id: 'ia', titulo: 'Uso de IA' },
  { id: 'aprovacao', titulo: 'Aprovação' },
  { id: 'independencia', titulo: 'Independência' },
]

const categorias = [
  { sigla: 'CAT. A', nome: 'Sátira baseada em fato real', texto: 'Parte de informação verdadeira e desenvolve uma interpretação inventada. O fato original é preservado e sua fonte é identificada e arquivada.' },
  { sigla: 'CAT. B', nome: 'Ficção satírica', texto: 'Situação inventada integralmente, com identificação clara de sátira. Personagens e instituições fictícios são reconhecíveis como tais.' },
  { sigla: 'CAT. C', nome: 'Observação e comentário', texto: 'Interpretação humorística sobre comportamento e sociedade, sem generalizações apresentadas como estatística ou resultado científico.' },
]

const proibicoes = [
  'Inventar declarações e atribuí-las a pessoas reais.',
  'Fabricar documentos e apresentá-los como oficiais.',
  'Inventar pesquisas e atribuí-las a instituições reais.',
  'Alterar o sentido de uma declaração original.',
  'Apresentar acusações não comprovadas como fatos.',
  'Criar montagens que simulem evidências de acontecimentos inexistentes.',
  'Retirar informações essenciais de contexto para produzir uma impressão enganosa.',
  'Atribuir a instituições públicas reais manifestações, posições ou decisões que não tomaram.',
]
</script>

<template>
  <div class="grid lg:grid-cols-[220px_1fr] gap-12">
    <nav class="self-start lg:sticky lg:top-6 flex flex-col gap-2 text-sm" aria-label="Nesta página">
      <RotuloSecao>Nesta página</RotuloSecao>
      <a v-for="s in secoes" :key="s.id" :href="`#${s.id}`" class="text-base-content no-underline hover:underline">{{ s.titulo }}</a>
    </nav>

    <article class="flex flex-col gap-6 max-w-3xl">
      <h1 class="font-serif font-extrabold text-4xl md:text-5xl tracking-tight m-0">Política editorial</h1>

      <section id="fatos-ficcao" class="flex flex-col gap-4 scroll-mt-6">
        <h2 class="font-serif font-extrabold text-2xl m-0">Fatos, ficção e transparência</h2>
        <p class="font-serif text-lg m-0">Existem três categorias editoriais. Toda matéria indica a sua.</p>
        <ul class="grid md:grid-cols-3 gap-4">
          <li v-for="c in categorias" :key="c.sigla" class="rounded-box border border-base-300 p-5 flex flex-col gap-2">
            <span class="font-mono text-xs font-semibold text-primary">{{ c.sigla }}</span>
            <span class="font-serif font-bold text-lg">{{ c.nome }}</span>
            <span class="text-sm text-base-content/80 leading-snug">{{ c.texto }}</span>
          </li>
        </ul>
        <blockquote class="rounded-box bg-base-200 p-5 font-serif m-0">
          <span class="block mb-2"><RotuloSecao>Aviso editorial padrão</RotuloSecao></span>
          {{ avisoEditorialPadrao }}
        </blockquote>
      </section>

      <section id="limites" class="prosa scroll-mt-6">
        <h2>O que nunca fazemos</h2>
        <ul>
          <li v-for="p in proibicoes" :key="p">{{ p }}</li>
        </ul>
        <p>
          Alvos preferenciais são autoridades, instituições, empresas, discursos públicos, decisões e comportamentos
          coletivos. Não satirizamos vítimas, menores de idade ou familiares, nem a aparência física de ninguém como
          piada em si. Pessoas privadas não são expostas.
        </p>
      </section>

      <section id="fontes" class="prosa scroll-mt-6">
        <h2>Fontes</h2>
        <p>
          Toda sátira da Categoria A parte de um acontecimento documentado. A fonte original é arquivada em três
          lugares (captura própria, cópia externa e Internet Archive) antes de a pauta avançar, para que o fato de origem
          continue verificável mesmo que o link original desapareça.
        </p>
      </section>

      <section id="ia" class="prosa scroll-mt-6">
        <h2>Uso de inteligência artificial</h2>
        <p class="font-serif text-xl"><strong>A IA rascunha. O humano decide.</strong></p>
        <p>
          A IA pode sugerir pautas, ângulos, manchetes e revisões, mas não aprova publicação. Nenhuma referência,
          citação ou estatística produzida por IA é considerada verificada sem conferência independente. Imagens geradas
          por IA são identificadas.
        </p>
      </section>

      <section id="aprovacao" class="prosa scroll-mt-6">
        <h2>Aprovação</h2>
        <p>Toda publicação passa por quatro verificações antes de ir ao ar:</p>
        <ol>
          <li><strong>Factual:</strong> a fonte existe, a informação e a data estão corretas, o contexto foi preservado.</li>
          <li><strong>Humorística:</strong> há uma piada identificável, com alvo claro e fechamento que não se explica.</li>
          <li><strong>Responsabilidade:</strong> ninguém privado é exposto, não há risco de leitura como notícia real, a ficção está identificada.</li>
          <li><strong>Editorial:</strong> o texto pertence ao Retórica dos Absurdos e merece ser publicado.</li>
        </ol>
        <p>
          Sátiras da Categoria A com alvo identificável também passam por um leitor externo, que não escreveu a peça.
          Se a matéria falhar na verificação factual ou tiver risco alto não resolvido, ela não é publicada.
        </p>
      </section>

      <section id="independencia" class="prosa scroll-mt-6">
        <h2>Independência</h2>
        <p>
          O site não exibe anúncios. Se um dia exibir, eles serão sempre rotulados "Publicidade", ficarão fora da
          manchete e do aviso de sátira, e anunciantes não escolherão pautas, alvos ou correções.
        </p>
      </section>
    </article>
  </div>
</template>
