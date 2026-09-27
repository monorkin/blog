import { handle } from "@astrojs/cloudflare/handler"
import { FEED_PATHS, feedPagePath, legacyFeedPath } from "~/lib/feed-paths"

type HandleArguments = Parameters<typeof handle>

const FEED_CONTENT_TYPE = "application/xml; charset=utf-8"

// The Worker's entry: Astro's handler, after the feed URLs it can't answer itself.
// `run_worker_first` in wrangler.jsonc sends only those to the Worker first.
//
// - The Rails app's feed URLs redirect on their query string, which `_redirects` can't match
//   or drop.
// - A feed's URL is its first page, built as <feed>/page/1: the later pages live in a
//   <feed>/page/ folder, and a file can't have the same name as a folder.
export default {
  async fetch(request: Request, env: HandleArguments[1], context: HandleArguments[2]) {
    const url = new URL(request.url)
    const location = legacyFeedPath(url)

    if (location) {
      return Response.redirect(new URL(location, url), 301)
    } else if (FEED_PATHS.includes(url.pathname)) {
      return firstFeedPage(url, env)
    } else {
      return handle(request, env, context)
    }
  }
}

async function firstFeedPage(url: URL, env: HandleArguments[1]) {
  const assets = (env as { ASSETS: { fetch(url: URL): Promise<Response> } }).ASSETS
  const page = await assets.fetch(new URL(feedPagePath(url.pathname, 1), url))

  return new Response(page.body, { status: page.status, headers: { "Content-Type": FEED_CONTENT_TYPE } })
}
