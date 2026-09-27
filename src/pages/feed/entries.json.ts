import { publishedEntries } from "~/lib/entries"
import { allTags } from "~/lib/tags"
import { SITE_URL } from "~/lib/site"
import type { FeedIndex } from "~/lib/feed"

// The on-demand /feed route filters this index instead of reading content collections at runtime
export async function GET() {
  const entries = await publishedEntries()
  const tags = await allTags()

  const index: FeedIndex = {
    tags: tags.map(tag => tag.name),
    entries: await Promise.all(entries.map(async entry => ({
      id: entry.feedId,
      kind: entry.kind,
      title: entry.title,
      path: entry.path,
      publishedAt: entry.publishedAt.toISOString(),
      updatedAt: entry.updatedAt.toISOString(),
      tags: entry.tags,
      content: `<div class="lexxy-content">\n  ${absolutizeUrls(await entry.html())}</div>\n`,
      summary: await entry.excerpt()
    })))
  }

  return new Response(JSON.stringify(index), { headers: { "Content-Type": "application/json" } })
}

function absolutizeUrls(html: string) {
  return html
    .replace(/\b(src|href|poster)="\/(?!\/)/g, `$1="${SITE_URL}/`)
    .replace(/\bsrcset="([^"]+)"/g, (_, srcset: string) => {
      const candidates = srcset.split(",").map(candidate => candidate.trim().replace(/^\/(?!\/)/, `${SITE_URL}/`))
      return `srcset="${candidates.join(", ")}"`
    })
}
