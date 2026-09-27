import { publishedEntries } from "~/lib/entries"
import { byCreation, urlset } from "~/lib/sitemaps"

export async function GET() {
  const talks = (await publishedEntries("talk")).sort(byCreation)
  return urlset(talks.map(talk => ({ path: talk.path, lastmod: talk.updatedAt, priority: "0.75" })))
}
