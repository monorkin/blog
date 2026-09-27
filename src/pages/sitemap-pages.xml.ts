import { publishedEntries } from "~/lib/entries"
import { listedProjects } from "~/lib/projects"
import { PROJECTS_ENABLED } from "~/lib/site"
import { aboutPageUpdatedAt, lastUpdated, urlset } from "~/lib/sitemaps"

export async function GET() {
  const pages: Parameters<typeof urlset>[0] = [
    { path: "/", lastmod: aboutPageUpdatedAt(), priority: "1.0" },
    { path: "/articles", lastmod: lastUpdated(await publishedEntries("article")), priority: "0.9" },
    { path: "/talks", lastmod: lastUpdated(await publishedEntries("talk")), priority: "0.9" },
    { path: "/snaps", lastmod: lastUpdated(await publishedEntries("snap")), priority: "0.9" }
  ]

  if (PROJECTS_ENABLED) {
    pages.push({ path: "/projects", priority: "0.9" }, ...listedProjects().map(project => ({ path: project.url, priority: "0.75" })))
  }

  return urlset(pages)
}
