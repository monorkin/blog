import type { CollectionEntry } from "astro:content"
import { publishedEntries, publishedTalks, type Entry } from "~/lib/entries"
import { markdownPath } from "~/lib/markdown"
import { AUTHOR_NAME, absoluteUrl, formatDate } from "~/lib/site"

// The site for language models, as llmstxt.org lays it out: who it is, then every entry's
// Markdown version. Snaps are photos, so they come last, under "Optional", which a model
// short on room may skip.
const EXCERPT_LENGTH = 160

export async function GET() {
  const [ articles, talks, snaps ] = await Promise.all([ publishedEntries("article"), publishedTalks(), publishedEntries("snap") ])

  const sections = [
    `# ${AUTHOR_NAME}`,
    `> The blog of ${AUTHOR_NAME}, a maker from Zagreb and a senior programmer at 37signals: articles about programming, Ruby on Rails and making software, the talks he's given, and photos. Every entry has a Markdown version at its URL plus ".md", which the links below point to.`,
    `## Articles\n\n${(await Promise.all(articles.map(articleLine))).join("\n")}`,
    `## Talks\n\n${talks.map(talkLine).join("\n")}`,
    `## Optional\n\n${snaps.map(snap => link(snap)).join("\n")}`
  ]

  return new Response(sections.join("\n\n") + "\n", {
    headers: { "Content-Type": "text/plain; charset=utf-8" }
  })
}

// The excerpt keeps its paragraphs; a list item needs them on one line
async function articleLine(article: Entry) {
  const excerpt = await article.excerpt(EXCERPT_LENGTH)
  return `${link(article)}: ${excerpt.replace(/\s+/g, " ")}`
}

function talkLine(talk: Entry) {
  const data = talk.source.data as CollectionEntry<"talks">["data"]
  return `${link(talk)}: a talk at ${data.event}, ${formatDate(data.heldAt)}`
}

function link(entry: Entry) {
  return `- [${entry.title}](${absoluteUrl(markdownPath(entry))})`
}
