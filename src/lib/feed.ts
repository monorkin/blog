import { AUTHOR_EMAIL, AUTHOR_NAME, SITE_URL } from "~/lib/site"

export interface FeedEntry {
  id: string
  kind: string
  title: string
  path: string
  publishedAt: string
  updatedAt: string
  tags: string[]
  content: string
  summary?: string
}

export interface FeedIndex {
  tags: string[]
  entries: FeedEntry[]
}

const KINDS = [ "article", "talk", "snap" ]
const FEED_HOST = new URL(SITE_URL).host

// Same semantics as the Rails FeedController: unknown types and tags are
// ignored, and a filter with nothing valid left in it doesn't filter at all.
export function filterEntries(index: FeedIndex, params: URLSearchParams) {
  const types = listParam(params, "types").filter(type => KINDS.includes(type))
  const tags = listParam(params, "tag").filter(tag => index.tags.includes(tag))
  let entries = index.entries

  if (types.length > 0) {
    entries = entries.filter(entry => types.includes(entry.kind))
  }

  if (tags.length > 0) {
    entries = entries.filter(entry => entry.tags.some(tag => tags.includes(tag)))
  }

  return entries
}

export function atomFeed(entries: FeedEntry[], requestUrl: URL) {
  const fullPath = `${requestUrl.pathname}${requestUrl.search}`
  const selfUrl = `${SITE_URL}${fullPath}`
  const lines = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<?xml-stylesheet href="/feed/style" type="text/xsl"?>',
    '<feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom">',
    `  <id>tag:${FEED_HOST},2005:${escape(fullPath)}</id>`,
    `  <link rel="alternate" type="text/html" href="${SITE_URL}/"/>`,
    `  <link rel="self" type="application/atom+xml" href="${escapeAttribute(selfUrl)}"/>`,
    `  <title>${AUTHOR_NAME}</title>`
  ]

  if (entries.length > 0) {
    lines.push(`  <updated>${timestamp(latestUpdate(entries))}</updated>`)
  }

  for (const entry of entries) {
    lines.push(...entryLines(entry))
  }

  lines.push("</feed>")

  return lines.join("\n") + "\n"
}

function entryLines(entry: FeedEntry) {
  let summary = '    <summary type="html"/>'

  if (entry.summary) {
    summary = `    <summary type="html">${escape(entry.summary)}</summary>`
  }

  return [
    "  <entry>",
    `    <id>tag:${FEED_HOST},2005:${entry.id}</id>`,
    `    <published>${timestamp(entry.publishedAt)}</published>`,
    `    <updated>${timestamp(entry.updatedAt)}</updated>`,
    `    <link rel="alternate" type="text/html" href="${SITE_URL}${escapeAttribute(entry.path)}"/>`,
    `    <title>${escape(entry.title)}</title>`,
    `    <content type="html">${escape(entry.content)}</content>`,
    summary,
    "    <author>",
    `      <name>${AUTHOR_NAME}</name>`,
    `      <email>${AUTHOR_EMAIL}</email>`,
    "    </author>",
    "  </entry>"
  ]
}

function listParam(params: URLSearchParams, name: string) {
  return (params.get(name) ?? "").split(",").filter(value => value !== "")
}

function latestUpdate(entries: FeedEntry[]) {
  return entries.map(entry => entry.updatedAt).sort().at(-1)!
}

function timestamp(iso: string) {
  return iso.replace(/\.\d{3}Z$/, "Z")
}

function escape(text: string) {
  return text.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;")
}

function escapeAttribute(text: string) {
  return escape(text).replaceAll("\"", "&quot;")
}
