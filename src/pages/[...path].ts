import type { APIRoute } from "astro"
import { env } from "cloudflare:workers"

export const prerender = false

const PATHS_INDEX = "/entry-paths.json"
const NOT_FOUND_PAGE = "/404.html"
const SECTIONS: Record<string, string> = { "": "article", talks: "talk", snaps: "snap" }

// Entries are identified by the ID at the end of their slug, so a URL with an
// outdated or mangled title still finds its entry, as it did in the Rails app.
export const GET: APIRoute = async ({ request }) => {
  const url = new URL(request.url)
  const entryPath = await canonicalPathFor(url)

  if (entryPath) {
    return Response.redirect(new URL(entryPath, url), 301)
  } else {
    const notFound = await env.ASSETS.fetch(new URL(NOT_FOUND_PAGE, url))
    return new Response(notFound.body, { status: 404, headers: { "Content-Type": "text/html; charset=utf-8" } })
  }
}

async function canonicalPathFor(url: URL) {
  const match = url.pathname.match(/^\/(?:(talks|snaps)\/)?([^/]+)$/)

  if (match) {
    const kind = SECTIONS[match[1] ?? ""]
    const slugId = match[2].split("-").at(-1)
    const entries: Array<{ kind: string, path: string }> = await (await env.ASSETS.fetch(new URL(PATHS_INDEX, url))).json()
    const entry = entries.find(candidate => candidate.kind === kind && candidate.path.split("-").at(-1) === slugId)

    if (entry && entry.path !== url.pathname) {
      return entry.path
    }
  }
}
