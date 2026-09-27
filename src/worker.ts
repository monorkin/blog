import { handle } from "@astrojs/cloudflare/handler"
import { legacyFeedPath } from "~/lib/feed-paths"

type HandleArguments = Parameters<typeof handle>

// The Worker's entry: Astro's handler, after one check it can't do itself. The feeds are
// built files, which Astro would serve before any route or middleware ran, and `_redirects`
// can't match or drop a query string, so the Rails app's feed URLs are redirected here.
// `run_worker_first` in wrangler.jsonc sends only those paths to the Worker first.
export default {
  async fetch(request: Request, env: HandleArguments[1], context: HandleArguments[2]) {
    const location = legacyFeedPath(new URL(request.url))

    if (location) {
      return Response.redirect(new URL(location, request.url), 301)
    } else {
      return handle(request, env, context)
    }
  }
}
