<script setup lang="ts">
const { recursos, canais } = useAppConfig()
const route = useRoute()

interface ItemMenu { rotulo: string, para: string, destaque?: boolean }

const menu = computed<ItemMenu[]>(() => {
  const itens: ItemMenu[] = [
    // Rótulos do menu como no design: dois nomes completos, três curtos.
    ...territorios.map(t => ({ rotulo: t.menu, para: `/t/${t.slug}` })),
    { rotulo: 'Formatos', para: '/f' },
  ]
  if (recursos.investigacoes) itens.push({ rotulo: 'Investigações', para: '/investigacoes' })
  if (recursos.absurdometro) itens.push({ rotulo: 'Absurdômetro', para: '/absurdometro', destaque: true })
  if (recursos.newsletter) itens.push({ rotulo: 'Newsletter', para: '/newsletter' })
  itens.push({ rotulo: 'Diário', para: '/diario' }, { rotulo: 'Sobre', para: '/sobre' })
  return itens
})

function ativo(para: string) {
  return route.path === para || route.path.startsWith(`${para}/`)
}

// A data é calculada no navegador: as páginas são pré-renderizadas e uma data
// gravada no build ficaria velha.
const hoje = ref('')
onMounted(() => {
  const texto = new Intl.DateTimeFormat('pt-BR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric', timeZone: 'America/Sao_Paulo' }).format(new Date())
  hoje.value = texto.charAt(0).toUpperCase() + texto.slice(1)
})

const menuAberto = ref(false)
watch(() => route.path, () => { menuAberto.value = false })
</script>

<template>
  <header class="w-full bg-base-100 text-base-content">
    <div class="bg-neutral text-neutral-content flex justify-between items-center px-4 md:px-10 py-2 text-[13px] gap-4">
      <div class="flex items-center gap-3">
        <SeloSatira />
        <span><span class="hidden sm:inline">Tudo aqui é sátira. Os fatos de origem, quando existem, são identificados.</span><span class="sm:hidden">Tudo aqui é sátira.</span></span>
      </div>
      <div v-if="canais.telegram || canais.instagram || recursos.newsletter" class="hidden md:flex gap-5 items-center">
        <a v-if="canais.telegram" :href="canais.telegram" class="flex items-center gap-1.5 text-neutral-content hover:text-neutral-content/80" rel="noopener"><Icon name="ion:paper-plane-outline" />Telegram</a>
        <a v-if="canais.instagram" :href="canais.instagram" class="flex items-center gap-1.5 text-neutral-content hover:text-neutral-content/80" rel="noopener"><Icon name="ion:logo-instagram" />Instagram</a>
        <NuxtLink v-if="recursos.newsletter" to="/newsletter" class="flex items-center gap-1.5 text-neutral-content hover:text-neutral-content/80"><Icon name="ion:mail-outline" />Newsletter</NuxtLink>
      </div>
    </div>

    <div class="grid grid-cols-[1fr_auto_1fr] items-center px-4 md:px-10 py-4 md:py-5 gap-3">
      <span class="text-[13px] text-base-content/70 hidden md:flex items-center gap-2 min-h-5">
        <template v-if="hoje"><Icon name="ion:calendar-outline" />{{ hoje }}</template>
      </span>
      <button
        class="btn btn-ghost btn-sm btn-circle md:hidden justify-self-start"
        :aria-expanded="menuAberto"
        aria-controls="menu-principal"
        aria-label="Abrir menu"
        @click="menuAberto = !menuAberto"
      >
        <Icon :name="menuAberto ? 'ion:close-outline' : 'ion:menu-outline'" class="text-xl" />
      </button>
      <NuxtLink to="/" class="flex flex-col items-center gap-1 no-underline hover:text-base-content" aria-label="Retórica dos Absurdos, página inicial">
        <MarcaRetorica />
        <span class="font-serif italic text-xs md:text-sm text-base-content/70 text-center">{{ lema }}</span>
      </NuxtLink>
      <div class="flex justify-end gap-2 items-center">
        <form v-if="recursos.busca" action="/busca" method="get" role="search" class="hidden md:block">
          <label class="input input-sm rounded-full w-52">
            <Icon name="ion:search-outline" />
            <input type="search" name="q" placeholder="Buscar absurdos" aria-label="Buscar absurdos">
          </label>
        </form>
        <NuxtLink v-if="recursos.newsletter" to="/newsletter" class="btn btn-primary btn-sm rounded-full">Assinar</NuxtLink>
      </div>
    </div>

    <nav
      id="menu-principal"
      class="border-y border-base-300 px-4 md:px-10 py-2"
      :class="menuAberto ? 'block' : 'hidden md:block'"
      aria-label="Principal"
    >
      <ul class="flex flex-col md:flex-row md:flex-wrap md:justify-center gap-1">
        <li v-for="item in menu" :key="item.para">
          <NuxtLink
            :to="item.para"
            class="block px-4 py-2 rounded-full text-sm font-semibold no-underline"
            :class="ativo(item.para)
              ? 'bg-neutral text-neutral-content hover:text-neutral-content'
              : item.destaque
                ? 'text-link border border-link/40'
                : 'text-base-content hover:bg-base-200'"
            :aria-current="ativo(item.para) ? 'page' : undefined"
          >
            {{ item.rotulo }}
          </NuxtLink>
        </li>
      </ul>
    </nav>
  </header>
</template>
