import { statSync } from "node:fs"
import { join } from "node:path"
import type { Entry } from "~/lib/entries"
import { absoluteUrl, isoTimestamp } from "~/lib/site"

export interface SitemapUrl {
  path: string
  lastmod?: Date
  priority: string
}

export function urlset(urls: SitemapUrl[]) {
  const entries = urls.map(url => [
    "  <url>",
    `    <loc>${escapeXml(absoluteUrl(url.path))}</loc>`,
    url.lastmod && `    <lastmod>${isoTimestamp(url.lastmod)}</lastmod>`,
    `    <priority>${url.priority}</priority>`,
    "  </url>"
  ].filter(Boolean).join("\n"))

  return xmlResponse([ '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">', ...entries, "</urlset>" ])
}

export function sitemapIndex(sitemaps: Array<{ path: string, lastmod?: Date }>) {
  const entries = sitemaps.map(sitemap => [
    "  <sitemap>",
    `    <loc>${escapeXml(absoluteUrl(sitemap.path))}</loc>`,
    sitemap.lastmod && `    <lastmod>${isoTimestamp(sitemap.lastmod)}</lastmod>`,
    "  </sitemap>"
  ].filter(Boolean).join("\n"))

  return xmlResponse([ '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">', ...entries, "</sitemapindex>" ])
}

export function lastUpdated(entries: Entry[]) {
  if (entries.length > 0) {
    return new Date(Math.max(...entries.map(entry => entry.updatedAt.getTime())))
  }
}

// The Rails app listed entries by record ID, so migrated entries keep their order and new ones follow
export function byCreation(a: Entry, b: Entry) {
  return a.legacyId - b.legacyId || a.publishedAt.getTime() - b.publishedAt.getTime()
}

// The about page has no data behind it, so it counts as updated when its template was
export function aboutPageUpdatedAt() {
  return statSync(join(process.cwd(), "src/pages/index.astro")).mtime
}

export function escapeXml(text: string) {
  return text.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\"", "&quot;")
}

function xmlResponse(lines: string[]) {
  const body = [ '<?xml version="1.0" encoding="UTF-8"?>', ...lines ].join("\n") + "\n"
  return new Response(body, { headers: { "Content-Type": "application/xml; charset=utf-8" } })
}
