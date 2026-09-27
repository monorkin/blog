import { publishedEntries } from "~/lib/entries"
import { aboutPageUpdatedAt, lastUpdated, urlset } from "~/lib/sitemaps"

const projects = Object.values(import.meta.glob<{ url: string }>("./projects/*.{md,mdx}", { eager: true }))

export async function GET() {
  return urlset([
    { path: "/", lastmod: aboutPageUpdatedAt(), priority: "1.0" },
    { path: "/articles", lastmod: lastUpdated(await publishedEntries("article")), priority: "0.9" },
    { path: "/talks", lastmod: lastUpdated(await publishedEntries("talk")), priority: "0.9" },
    { path: "/snaps", lastmod: lastUpdated(await publishedEntries("snap")), priority: "0.9" },
    { path: "/projects", priority: "0.9" },
    ...projects.map(project => ({ path: project.url, priority: "0.75" }))
  ])
}
