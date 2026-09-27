import { publishedEntries } from "~/lib/entries"
import { byCreation, urlset } from "~/lib/sitemaps"

export async function GET() {
  const articles = (await publishedEntries("article")).sort(byCreation)
  return urlset(articles.map(article => ({ path: article.path, lastmod: article.updatedAt, priority: "0.75" })))
}
