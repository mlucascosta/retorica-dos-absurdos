import { defineCollection, defineContentConfig } from '@nuxt/content'
import { z } from 'zod'

export default defineContentConfig({
  collections: {
    diario: defineCollection({
      type: 'page',
      source: 'diario/*.md',
      schema: z.object({
        data: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
        resumo: z.string(),
        marco: z.string().optional(),
      }),
    }),
  },
})
