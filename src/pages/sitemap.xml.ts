import { publishedEntries } from "~/lib/entries"
import { aboutPageUpdatedAt, lastUpdated, sitemapIndex } from "~/lib/sitemaps"
import { allTags } from "~/lib/tags"

export async function GET() {
  const tags = await allTags()

  return sitemapIndex([
    { path: "/sitemap-pages.xml", lastmod: aboutPageUpdatedAt() },
    { path: "/sitemap-articles.xml", lastmod: lastUpdated(await publishedEntries("article")) },
    { path: "/sitemap-talks.xml", lastmod: lastUpdated(await publishedEntries("talk")) },
    { path: "/sitemap-tags.xml", lastmod: new Date(Math.max(...tags.map(tag => tag.updatedAt.getTime()))) },
    { path: "/sitemap-snaps.xml", lastmod: lastUpdated(await publishedEntries("snap")) }
  ])
}
