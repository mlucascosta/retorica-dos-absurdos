/**
 * Taxonomias e textos de referência do Manual Editorial v1.0 e do Addendum v1.1.
 * No M1 os territórios, formatos e técnicas passam para o banco (tabela `taxonomias`);
 * até lá, esta é a fonte única.
 */

export interface Territorio {
  slug: string
  nome: string
  menu: string
  descricao: string
}

export interface Formato {
  numero: number
  slug: string
  nome: string
  curto: string
  descricao: string
  tarja?: string
}

export const territorios: Territorio[] = [
  {
    slug: 'politica-e-poder',
    nome: 'Política e poder',
    menu: 'Política e poder',
    descricao: 'Governos, Congresso, campanhas, discursos, promessas, decisões administrativas e a distância entre o que se diz e o que se faz.',
  },
  {
    slug: 'sociedade-e-cotidiano',
    nome: 'Sociedade e cotidiano',
    menu: 'Sociedade',
    descricao: 'Comportamento, família, trabalho, educação, consumo, relacionamentos, costumes e os hábitos que todo brasileiro reconhece.',
  },
  {
    slug: 'economia-e-consumo',
    nome: 'Economia e consumo',
    menu: 'Economia',
    descricao: 'Bancos, publicidade, preços, empresas, mercado de trabalho, empreendedorismo e promessas comerciais.',
  },
  {
    slug: 'tecnologia-e-internet',
    nome: 'Tecnologia e internet',
    menu: 'Tecnologia',
    descricao: 'Inteligência artificial, redes sociais, influenciadores, aplicativos, cultura de produtividade, cursos e gurus digitais.',
  },
  {
    slug: 'cultura-e-mundo',
    nome: 'Cultura e mundo',
    menu: 'Cultura e mundo',
    descricao: 'Cinema, música, televisão, celebridades, esportes, cultura popular e acontecimentos internacionais, com sotaque brasileiro.',
  },
]

export const formatos: Formato[] = [
  {
    numero: 1,
    slug: 'noticia-absurda',
    nome: 'Notícia absurda',
    curto: 'Notícia',
    descricao: 'O formato principal. Parte de um acontecimento verificável e desenvolve uma interpretação satírica: manchete, subtítulo, contexto, escalada e fechamento.',
  },
  {
    numero: 2,
    slug: 'documentos-e-instituicoes',
    nome: 'Documentos e instituições',
    curto: 'Documentos',
    descricao: 'Paródias de portarias, circulares, editais, atas e comunicados, sempre emitidos por órgãos manifestamente fictícios.',
    tarja: 'DOCUMENTO FICTÍCIO — SÁTIRA',
  },
  {
    numero: 3,
    slug: 'pesquisas-e-levantamentos',
    nome: 'Pesquisas e levantamentos',
    curto: 'Pesquisas',
    descricao: 'Estudos inventados por institutos que não existem, com precisão descabida e aviso acima de cada número.',
    tarja: 'PESQUISA INVENTADA',
  },
  {
    numero: 4,
    slug: 'entrevistas-impossiveis',
    nome: 'Entrevistas impossíveis',
    curto: 'Entrevistas',
    descricao: 'Conversas com personagens de cargos manifestamente fictícios, identificados como tal desde a manchete.',
  },
  {
    numero: 5,
    slug: 'listas-e-rankings',
    nome: 'Listas e rankings',
    curto: 'Listas',
    descricao: 'Observação do cotidiano organizada em itens. Curtas, compartilháveis e com o fechamento no último item.',
  },
  {
    numero: 6,
    slug: 'observatorio-do-absurdo',
    nome: 'Observatório do absurdo',
    curto: 'Observatório',
    descricao: 'Padrões reais do discurso institucional e corporativo, observados com lupa: o eufemismo, a nota oficial, o "em análise".',
  },
  {
    numero: 7,
    slug: 'internet-em-estado-terminal',
    nome: 'Internet em estado terminal',
    curto: 'Internet',
    descricao: 'Influenciadores, gurus, cursos que vendem cursos e a lógica das plataformas levada às últimas consequências.',
  },
  {
    numero: 8,
    slug: 'a-realidade-supera-a-satira',
    nome: 'A realidade supera a sátira',
    curto: 'Realidade',
    descricao: 'Fatos reais, documentados e arquivados, publicados sem nenhuma alteração. Nenhuma piada foi necessária.',
  },
]

export const tecnicas = [
  'Exagero',
  'Literalização',
  'Inversão',
  'Burocratização',
  'Eufemismo',
  'Precisão absurda',
  'Falsa solenidade',
  'Escalada',
  'Contraste',
  'Autossátira',
  'Incompetência institucional',
  'Hipocrisia',
] as const

export const avisoEditorialPadrao
  = 'Este conteúdo é uma obra de sátira e humor. A interpretação, os personagens e os elementos ficcionais são intencionais. Quando houver um fato real como ponto de partida, sua origem será identificada.'

export const lema = 'A realidade não precisa de nossa ajuda para ser absurda.'

export const dozeRegras = [
  'A realidade é nossa matéria-prima.',
  'A piada precisa ter um alvo.',
  'A manchete deve despertar curiosidade.',
  'O texto não deve explicar a própria piada.',
  'O humor deve ser ácido, mas inteligente.',
  'A política não é nossa única fonte de inspiração.',
  'A ficção nunca deve ser apresentada deliberadamente como fato.',
  'A IA auxilia; o humano responde.',
  'A qualidade prevalece sobre a frequência.',
  'A liberdade editorial não elimina a responsabilidade.',
  'A publicação deve possuir identidade própria.',
  'O próprio Retórica dos Absurdos também pode ser absurdo.',
]

export function territorioPorSlug(slug: string) {
  return territorios.find(t => t.slug === slug)
}

export function formatoPorSlug(slug: string) {
  return formatos.find(f => f.slug === slug)
}
