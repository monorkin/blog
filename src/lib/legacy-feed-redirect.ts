import type { APIRoute } from "astro"

// The old article feeds become the unified feed filtered to articles. They
// need a Worker because _redirects can't carry the `tag` parameter over.
export const redirectToArticleFeed: APIRoute = ({ request }) => {
  const url = new URL(request.url)
  const query = new URLSearchParams()
  const tag = url.searchParams.get("tag")

  if (tag) {
    query.set("tag", tag)
  }

  query.set("types", "article")

  return new Response(null, { status: 301, headers: { Location: `/feed?${query}` } })
}
