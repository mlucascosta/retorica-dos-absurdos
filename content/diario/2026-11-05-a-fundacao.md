---
title: A redação começa pelo lugar onde vai trabalhar
data: '2026-11-05'
resumo: Por que o Retórica dos Absurdos é construído em público, o que fica aberto, o que fica fechado e o que já está de pé.
marco: M0 · Fundação
---

O Retórica dos Absurdos é uma publicação de sátira brasileira. Antes da primeira matéria, existe um manual editorial, uma revisão crítica desse manual e um addendum que corrige a revisão. É a quantidade certa de burocracia para um projeto que pretende rir da burocracia.

Este diário registra a construção do site e do sistema editorial por trás dele.

## Por que construir em público

Porque uma publicação de sátira pede ao leitor que confie no critério dela. Mostrar como as regras viram código é uma forma de mostrar o critério. Quando o manual diz que nenhuma matéria vai ao ar sem quatro verificações, o código-fonte deixa qualquer pessoa conferir se isso é verdade.

## O que é aberto e o que não é

Aberto: o código, as migrações do banco, as decisões técnicas, o roadmap e este diário.

Fechado, e vai continuar assim: pautas, rascunhos, alvos em estudo, peças recusadas e os motivos, pareceres jurídicos e qualquer dado de leitor. Abrir a pauta antes da publicação mata a piada. Abrir as recusas transforma o registro editorial, que existe para provar critério, em material contra o próprio critério.

## O que já está de pé

- O site em Nuxt 4, rodando em Node.js 26 LTS na Vercel.
- O tema visual do projeto em Tailwind e daisyUI, num único arquivo, com fontes e ícones servidos pelo próprio site. Nenhuma requisição ao Google para desenhar uma letra.
- As páginas que o manual exige antes de qualquer matéria: manifesto e as doze regras, política editorial, política de correções e identificação de sátira.
- Cabeçalhos de segurança, varredura de segredos em cada pull request e um fluxo de ramos com homologação separada da produção.

## Um ajuste no design, por acessibilidade

O vermelho principal do design, com texto branco por cima, ficava com contraste de 3,5 para 1. O mínimo para texto pequeno é 4,5. Isso afetava justamente o selo SÁTIRA, o elemento que mais precisa ser lido. O selo passou para um tom um pouco mais escuro do mesmo vermelho, que chega a 4,6. Um teste automático recalcula esse contraste a cada mudança no tema.

## Próximo passo

O M1: o banco de dados. As regras do manual vão morar no próprio banco, e não só na interface. Se um dia a tela tiver um bug que deixe publicar sem verificação, o banco recusa mesmo assim.
