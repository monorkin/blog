import { urlset } from "~/lib/sitemaps"
import { allTags } from "~/lib/tags"

export async function GET() {
  const tags = (await allTags()).filter(tag => tag.entries.length > 0)
  return urlset(tags.map(tag => ({ path: `/tags/${tag.name}`, lastmod: tag.updatedAt, priority: "0.7" })))
}
