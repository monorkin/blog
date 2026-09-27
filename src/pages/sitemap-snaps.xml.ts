import { publishedEntries } from "~/lib/entries"
import { byCreation, urlset } from "~/lib/sitemaps"

export async function GET() {
  const snaps = (await publishedEntries("snap")).sort(byCreation)
  return urlset(snaps.map(snap => ({ path: snap.path, lastmod: snap.updatedAt, priority: "0.5" })))
}
