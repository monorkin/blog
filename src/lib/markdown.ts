import type { CollectionEntry } from "astro:content"
import type { Entry } from "~/lib/entries"
import { originalUrl, variantAtLeast } from "~/lib/media"
import { AUTHOR_NAME, SITE_URL } from "~/lib/site"

// An entry as Markdown, served at its URL plus ".md" and listed in /llms.txt, for language
// models and anyone else who'd rather read the text than the page

// The image a Markdown version links to, the size the lightbox shows
const IMAGE_WIDTH = 1600
const COMPONENT = /<(Figure|Video)\b([\s\S]*?)\/>/g
const GALLERY_TAG = /^[ \t]*<\/?Gallery>[ \t]*\n?/gm
const ATTRIBUTE = /(\w+)="([^"]*)"/g
const ROOT_RELATIVE_LINK = /\]\(\/(?!\/)/g

export function markdownResponse(entry: Entry) {
  return new Response(entryMarkdown(entry), {
    headers: { "Content-Type": "text/markdown; charset=utf-8" }
  })
}

export function markdownPath(entry: Entry) {
  return `${entry.path}.md`
}

// Its details as YAML frontmatter, then the title, then the body
export function entryMarkdown(entry: Entry) {
  return `---\n${frontmatter(entry).join("\n")}\n---\n\n# ${entry.title}\n\n${body(entry).trim()}\n`
}

function frontmatter(entry: Entry) {
  const fields = [
    `title: ${JSON.stringify(entry.title)}`,
    `url: ${entry.url}`,
    `author: ${AUTHOR_NAME}`,
    `published: ${isoDate(entry.publishedAt)}`,
    `updated: ${isoDate(entry.updatedAt)}`
  ]

  if (entry.tags.length > 0) {
    fields.push(`tags: [${entry.tags.join(", ")}]`)
  }

  if (entry.kind === "talk") {
    fields.push(...talkFields(entry))
  }

  return fields
}

function talkFields(entry: Entry) {
  const talk = entry.source.data as CollectionEntry<"talks">["data"]
  const fields = [ `event: ${JSON.stringify(talk.event)}`, `kind: ${talk.kind}`, `held: ${isoDate(talk.heldAt)}` ]

  if (talk.eventUrl) {
    fields.push(`eventUrl: ${talk.eventUrl}`)
  }

  if (talk.video) {
    fields.push(`video: ${originalUrl(entry.mediaKey(talk.video))}`)
  }

  if (talk.videoMirrorUrl) {
    fields.push(`videoMirror: ${talk.videoMirrorUrl}`)
  }

  return fields
}

function body(entry: Entry) {
  if (entry.kind === "snap") {
    return snapBody(entry)
  } else {
    return withoutComponents(entry.source.body ?? "", entry).replace(ROOT_RELATIVE_LINK, `](${SITE_URL}/`)
  }
}

// A snap has no body: it's its photo or video, and the caption
function snapBody(entry: Entry) {
  const snap = entry.source.data as CollectionEntry<"snaps">["data"]
  const parts = []

  if (snap.image) {
    parts.push(`![${snap.caption ?? entry.title}](${variantAtLeast(entry.mediaKey(snap.image), IMAGE_WIDTH)})`)
  } else if (snap.video) {
    parts.push(`[Video: ${entry.title}](${originalUrl(entry.mediaKey(snap.video))})`)
  }

  if (snap.caption) {
    parts.push(snap.caption)
  }

  return parts.join("\n\n")
}

// A figure becomes an image, with its caption as the alt text, a video a link to the file,
// and a gallery just its figures
function withoutComponents(source: string, entry: Entry) {
  return source.replace(GALLERY_TAG, "").replace(COMPONENT, (_, name: string, attributeText: string) => {
    const attributes = Object.fromEntries([ ...attributeText.matchAll(ATTRIBUTE) ].map(([ , key, value ]) => [ key, value ]))
    const key = entry.mediaKey(attributes.media)

    if (name === "Figure") {
      return `![${attributes.caption ?? ""}](${variantAtLeast(key, IMAGE_WIDTH)})`
    } else {
      return `[${videoLabel(attributes.caption)}](${originalUrl(key)})`
    }
  })
}

function videoLabel(caption?: string) {
  if (caption) {
    return `Video: ${caption}`
  } else {
    return "Video"
  }
}

function isoDate(date: Date) {
  return date.toISOString().slice(0, 10)
}
