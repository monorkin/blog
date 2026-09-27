import { feedFor, feedResponse } from "~/lib/feed"

export async function GET() {
  return feedResponse(feedFor("snap"))
}
