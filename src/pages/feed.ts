import type { APIRoute } from "astro"
import { env } from "cloudflare:workers"
import { atomFeed, filterEntries, type FeedIndex } from "~/lib/feed"

export const prerender = false

const INDEX_PATH = "/feed/entries.json"

export const GET: APIRoute = async ({ request }) => {
  const url = new URL(request.url)
  const response = await env.ASSETS.fetch(new URL(INDEX_PATH, url))
  const index: FeedIndex = await response.json()

  return new Response(atomFeed(filterEntries(index, url.searchParams), url), {
    headers: {
      "Content-Type": "application/xml; charset=utf-8",
      "Cache-Control": "public, max-age=300"
    }
  })
}
