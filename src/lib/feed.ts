import { publishedEntries, type Entry, type Kind } from "~/lib/entries"
import { FEED_PATH, KIND_FEED_PATHS } from "~/lib/feed-paths"
import { AUTHOR_EMAIL, AUTHOR_NAME, SITE_URL } from "~/lib/site"

export interface Feed {
  path: string
  title: string
  label: string
  kind?: Kind
}

// Four static Atom feeds: everything, and one per kind of entry
export const FEEDS: Feed[] = [
  { path: FEED_PATH, title: AUTHOR_NAME, label: "Everything" },
  { path: KIND_FEED_PATHS.article, title: `${AUTHOR_NAME}: Articles`, label: "Articles", kind: "article" },
  { path: KIND_FEED_PATHS.talk, title: `${AUTHOR_NAME}: Talks`, label: "Talks", kind: "talk" },
  { path: KIND_FEED_PATHS.snap, title: `${AUTHOR_NAME}: Snaps`, label: "Snaps", kind: "snap" }
]

export const STYLESHEET_PATH = "/feed.xsl"

const FEED_HOST = new URL(SITE_URL).host

export function feedFor(kind?: Kind) {
  return FEEDS.find(feed => feed.kind === kind)!
}

export async function feedResponse(feed: Feed) {
  return new Response(await atomFeed(feed, await publishedEntries(feed.kind)), {
    headers: { "Content-Type": "application/xml; charset=utf-8" }
  })
}

async function atomFeed(feed: Feed, entries: Entry[]) {
  const lines = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    `<?xml-stylesheet href="${STYLESHEET_PATH}" type="text/xsl"?>`,
    '<feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom">',
    `  <id>tag:${FEED_HOST},2005:${feed.path}</id>`,
    `  <link rel="alternate" type="text/html" href="${SITE_URL}/"/>`,
    `  <link rel="self" type="application/atom+xml" href="${SITE_URL}${feed.path}"/>`,
    `  <title>${escape(feed.title)}</title>`
  ]

  if (entries.length > 0) {
    lines.push(`  <updated>${timestamp(latestUpdate(entries))}</updated>`)
  }

  for (const entry of entries) {
    lines.push(...await entryLines(entry))
  }

  lines.push("</feed>")

  return lines.join("\n") + "\n"
}

function latestUpdate(entries: Entry[]) {
  return entries.map(entry => entry.updatedAt).sort((a, b) => a.getTime() - b.getTime()).at(-1)!
}

async function entryLines(entry: Entry) {
  const content = `<div class="lexxy-content">\n  ${absolutizeUrls(await entry.html())}</div>\n`
  const excerpt = await entry.excerpt()
  let summary = '    <summary type="html"/>'

  if (excerpt) {
    summary = `    <summary type="html">${escape(excerpt)}</summary>`
  }

  return [
    "  <entry>",
    `    <id>tag:${FEED_HOST},2005:${entry.feedId}</id>`,
    `    <published>${timestamp(entry.publishedAt)}</published>`,
    `    <updated>${timestamp(entry.updatedAt)}</updated>`,
    `    <link rel="alternate" type="text/html" href="${SITE_URL}${escapeAttribute(entry.path)}"/>`,
    `    <title>${escape(entry.title)}</title>`,
    `    <content type="html">${escape(content)}</content>`,
    summary,
    "    <author>",
    `      <name>${AUTHOR_NAME}</name>`,
    `      <email>${AUTHOR_EMAIL}</email>`,
    "    </author>",
    "  </entry>"
  ]
}

// Feed readers show the content away from the site, so its links and images need the host
function absolutizeUrls(html: string) {
  return html
    .replace(/\b(src|href|poster)="\/(?!\/)/g, `$1="${SITE_URL}/`)
    .replace(/\bsrcset="([^"]+)"/g, (_, srcset: string) => {
      const candidates = srcset.split(",").map(candidate => candidate.trim().replace(/^\/(?!\/)/, `${SITE_URL}/`))
      return `srcset="${candidates.join(", ")}"`
    })
}

function timestamp(date: Date) {
  return date.toISOString().replace(/\.\d{3}Z$/, "Z")
}

function escape(text: string) {
  return text.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;")
}

function escapeAttribute(text: string) {
  return escape(text).replaceAll("\"", "&quot;")
}
