import { experimental_AstroContainer as AstroContainer } from "astro/container"
import { loadRenderers } from "astro:container"
import { getContainerRenderer } from "@astrojs/mdx/container-renderer"
import { render, type CollectionEntry } from "astro:content"
import Figure from "~/components/content/Figure.astro"
import Gallery from "~/components/content/Gallery.astro"
import Video from "~/components/content/Video.astro"

type RenderableEntry = CollectionEntry<"articles"> | CollectionEntry<"talks">

// Every entry can use these without importing them
const CONTENT_COMPONENTS = { Figure, Gallery, Video }

let container: Promise<AstroContainer> | undefined
const renderedHtml = new Map<string, Promise<string>>()

export function renderToHtml(entry: RenderableEntry) {
  const key = `${entry.collection}/${entry.id}`

  if (!renderedHtml.has(key)) {
    renderedHtml.set(key, renderEntry(entry))
  }

  return renderedHtml.get(key)!
}

// The entry's folder goes along as `mediaFolder`, so its media keys can be just file names
async function renderEntry(entry: RenderableEntry) {
  const { Content } = await render(entry)

  return (await sharedContainer()).renderToString(Content, {
    props: { components: CONTENT_COMPONENTS },
    locals: { mediaFolder: `${entry.collection}/${entry.id}` } as App.Locals
  })
}

function sharedContainer() {
  if (!container) {
    container = loadRenderers([ getContainerRenderer() ]).then(renderers => AstroContainer.create({ renderers }))
  }

  return container
}
