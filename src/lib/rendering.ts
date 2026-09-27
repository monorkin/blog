import { experimental_AstroContainer as AstroContainer } from "astro/container"
import { loadRenderers } from "astro:container"
import { getContainerRenderer } from "@astrojs/mdx/container-renderer"
import { render, type CollectionEntry } from "astro:content"

type RenderableEntry = CollectionEntry<"articles"> | CollectionEntry<"talks">

let container: Promise<AstroContainer> | undefined
const renderedHtml = new Map<string, Promise<string>>()

export function renderToHtml(entry: RenderableEntry) {
  const key = `${entry.collection}/${entry.id}`

  if (!renderedHtml.has(key)) {
    renderedHtml.set(key, renderEntry(entry))
  }

  return renderedHtml.get(key)!
}

async function renderEntry(entry: RenderableEntry) {
  const { Content } = await render(entry)
  return (await sharedContainer()).renderToString(Content)
}

function sharedContainer() {
  if (!container) {
    container = loadRenderers([ getContainerRenderer() ]).then(renderers => AstroContainer.create({ renderers }))
  }

  return container
}
