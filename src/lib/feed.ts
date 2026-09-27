import { publishedEntries, type Entry, type Kind } from "~/lib/entries"
import { FEED_PATH, KIND_FEED_PATHS, feedPagePath } from "~/lib/feed-paths"
import { AUTHOR_EMAIL, AUTHOR_NAME, SITE_URL } from "~/lib/site"

export interface Feed {
  path: string
  title: string
  label: string
  kind?: Kind
}

export interface FeedPage {
  number: number
  count: number
  entries: Entry[]
}

export const FEED_PAGE_SIZE = 50

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

// A feed's pages, for getStaticPaths: every one of them, the first included
export async function feedPages(feed: Feed) {
  const entries = await publishedEntries(feed.kind)
  const count = Math.max(1, Math.ceil(entries.length / FEED_PAGE_SIZE))

  return Array.from({ length: count }, (_, index) => {
    const number = index + 1
    const page = { number, count, entries: entries.slice(index * FEED_PAGE_SIZE, number * FEED_PAGE_SIZE) }
    return { params: { page: String(number) }, props: { page } }
  })
}

export async function feedPageResponse(feed: Feed, page: FeedPage) {
  return new Response(await atomFeed(feed, page), {
    headers: { "Content-Type": "application/xml; charset=utf-8" }
  })
}

// RFC 5005 paging: the first page is the feed's own URL, and every page links to the others
async function atomFeed(feed: Feed, page: FeedPage) {
  const lines = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    `<?xml-stylesheet href="${STYLESHEET_PATH}" type="text/xsl"?>`,
    '<feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom">',
    `  <id>tag:${FEED_HOST},2005:${feed.path}</id>`,
    `  <link rel="alternate" type="text/html" href="${SITE_URL}/"/>`,
    ...pageLinks(feed, page),
    `  <title>${escape(feed.title)}</title>`
  ]
  const entries = page.entries

  if (entries.length > 0) {
    lines.push(`  <updated>${timestamp(latestUpdate(entries))}</updated>`)
  }

  for (const entry of entries) {
    lines.push(...await entryLines(entry))
  }

  lines.push("</feed>")

  return lines.join("\n") + "\n"
}

function pageLinks(feed: Feed, page: FeedPage) {
  const links = [ [ "self", page.number ], [ "first", 1 ] ]

  if (page.number > 1) {
    links.push([ "previous", page.number - 1 ])
  }

  if (page.number < page.count) {
    links.push([ "next", page.number + 1 ])
  }

  links.push([ "last", page.count ])

  return links.map(([ rel, number ]) => `  <link rel="${rel}" type="application/atom+xml" href="${SITE_URL}${pageUrl(feed, Number(number))}"/>`)
}

function pageUrl(feed: Feed, number: number) {
  if (number === 1) {
    return feed.path
  } else {
    return feedPagePath(feed.path, number)
  }
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
