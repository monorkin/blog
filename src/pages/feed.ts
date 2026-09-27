import { feedFor, feedResponse } from "~/lib/feed"

// Built like every other page. The Worker sees /feed first only to redirect the Rails
// app's `?types=` URLs (src/worker.ts)
export async function GET() {
  return feedResponse(feedFor())
}
