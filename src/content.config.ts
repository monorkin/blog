import { defineCollection } from "astro:content"
import { glob } from "astro/loaders"
import { z } from "astro/zod"

const entryFields = {
  title: z.string(),
  publishedAt: z.coerce.date(),
  updatedAt: z.coerce.date(),
  tags: z.array(z.string()).default([]),
  // The image a link to the entry shows when shared, a media key; without one it gets a
  // generated preview card (src/lib/social-image.ts), and a snap its photo
  ogImage: z.string().optional(),
  feedId: z.string().optional()
}

function entriesIn(directory: string, extension: string) {
  return glob({
    pattern: `*/index.${extension}`,
    base: `./src/content/${directory}`,
    generateId: ({ entry }) => entry.split("/")[0]
  })
}

const articles = defineCollection({
  loader: entriesIn("articles", "{md,mdx}"),
  schema: z.object(entryFields)
})

const talks = defineCollection({
  loader: entriesIn("talks", "{md,mdx}"),
  schema: z.object({
    ...entryFields,
    event: z.string(),
    kind: z.enum([ "conference", "meetup" ]),
    eventUrl: z.url().optional(),
    heldAt: z.coerce.date(),
    // Media keys, relative to the talk (src/lib/media.ts): the recording and its poster
    video: z.string().optional(),
    poster: z.string().optional(),
    videoMirrorUrl: z.url().optional()
  })
})

const snaps = defineCollection({
  loader: entriesIn("snaps", "md"),
  // image, video and poster are media keys (src/lib/media.ts)
  schema: z.object({
    ...entryFields,
    caption: z.string().optional(),
    image: z.string().optional(),
    video: z.string().optional(),
    videoType: z.string().optional(),
    duration: z.number().optional(),
    poster: z.string().optional()
  })
})

export const collections = { articles, talks, snaps }
