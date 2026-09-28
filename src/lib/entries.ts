import { getCollection, type CollectionEntry } from "astro:content"
import { findMedia, posterFor, resolveMediaKey } from "~/lib/media"
import { plainText } from "~/lib/plain-text"
import { renderToHtml } from "~/lib/rendering"
import { absoluteUrl, truncate } from "~/lib/site"

type Source = CollectionEntry<"articles"> | CollectionEntry<"talks"> | CollectionEntry<"snaps">
export type Kind = "article" | "talk" | "snap"

const KINDS: Record<Source["collection"], Kind> = { articles: "article", talks: "talk", snaps: "snap" }
const WORDS_PER_MINUTE = 225
const BUILD_TIME = new Date()


export class Entry {
  readonly source: Source

  constructor(source: Source) {
    this.source = source
  }

  get kind(): Kind {
    return KINDS[this.source.collection]
  }

  get id() {
    return this.source.id
  }

  get title() {
    return this.source.data.title
  }

  get publishedAt() {
    return this.source.data.publishedAt
  }

  get updatedAt() {
    return this.source.data.updatedAt
  }

  get tags() {
    return [ ...this.source.data.tags ].sort()
  }

  get published() {
    return !this.source.data.draft && this.publishedAt <= BUILD_TIME
  }

  get path() {
    switch (this.kind) {
      case "article": return `/${this.id}`
      case "talk": return `/talks/${this.id}`
      case "snap": return `/snaps/${this.id}`
    }
  }

  get url() {
    return absoluteUrl(this.path)
  }

  // Only the ID at the end of the folder name, so renaming an entry doesn't make it new in
  // feed readers
  get feedId() {
    return this.source.data.feedId ?? `${this.kind[0].toUpperCase()}${this.kind.slice(1)}/${this.id.split("-").at(-1)}`
  }

  // The Rails app broke ties between equal publish times by record ID
  get legacyId() {
    return Number(this.source.data.feedId?.split("/")[1] ?? Number.MAX_SAFE_INTEGER)
  }

  async html() {
    if (this.source.collection === "snaps") {
      return this.source.data.caption ?? ""
    } else {
      return renderToHtml(this.source)
    }
  }

  async plainText() {
    return plainText(await this.html())
  }

  async excerpt(length = 300) {
    return truncate(await this.plainText(), length) || undefined
  }

  async readingTime() {
    const words = (await this.plainText()).match(/\w+/g)?.length ?? 0
    return Math.max(Math.ceil(words / WORDS_PER_MINUTE), 1)
  }

  // Where the entry's own media lives, which its media keys are relative to
  get mediaFolder() {
    return `${this.source.collection}/${this.id}`
  }

  mediaKey(key: string) {
    return resolveMediaKey(key, this.mediaFolder)
  }

  // A full media key: a snap's photo, or an article's first figure
  coverImage(): string | undefined {
    let key

    if (this.source.collection === "snaps" && this.source.data.image) {
      key = this.source.data.image
    } else if (this.source.collection === "snaps") {
      return this.posterKey()
    } else if (this.source.collection === "articles") {
      key = this.source.body?.match(/<Figure media=(["'])(.+?)\1/)?.[2]
    }

    if (key) {
      return this.mediaKey(key)
    }
  }

  // A snap's or talk's video: its `poster` when it names one, or the image beside the video
  posterKey(): string | undefined {
    const { poster, video } = this.source.data as { poster?: string, video?: string }

    if (poster) {
      return this.mediaKey(poster)
    } else if (video) {
      return posterFor(this.mediaKey(video))
    }
  }

  // A video snap's length in seconds: its `duration`, or the video's in the manifest
  videoDuration(): number | undefined {
    const { duration, video } = this.source.data as { duration?: number, video?: string }

    if (duration) {
      return duration
    } else if (video) {
      return findMedia(this.mediaKey(video)).duration
    }
  }
}

export async function publishedEntries(kind?: Kind) {
  const sources = await sourcesFor(kind)

  return sources
    .map(source => new Entry(source))
    .filter(entry => entry.published)
    .sort(byRecency)
}

// Talks are listed by when they were held, not when they were published
export async function publishedTalks() {
  const talks = await publishedEntries("talk")

  return talks.sort((a, b) => {
    const [ talkA, talkB ] = [ a.source.data as CollectionEntry<"talks">["data"], b.source.data as CollectionEntry<"talks">["data"] ]

    return talkB.heldAt.getTime() - talkA.heldAt.getTime() ||
      talkA.title.localeCompare(talkB.title) ||
      talkA.event.localeCompare(talkB.event)
  })
}

export function byRecency(a: Entry, b: Entry) {
  return b.publishedAt.getTime() - a.publishedAt.getTime() || b.legacyId - a.legacyId
}

async function sourcesFor(kind?: Kind): Promise<Source[]> {
  switch (kind) {
    case "article": return getCollection("articles")
    case "talk": return getCollection("talks")
    case "snap": return getCollection("snaps")
    default: return [ ...await getCollection("articles"), ...await getCollection("talks"), ...await getCollection("snaps") ]
  }
}
