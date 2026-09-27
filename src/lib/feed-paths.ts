// The feeds' URLs, apart from src/lib/feed.ts so the Worker can use them without pulling in
// the content collections

export const FEED_PATH = "/feed"
export const KIND_FEED_PATHS: Record<string, string> = { article: "/articles/feed", talk: "/talks/feed", snap: "/snaps/feed" }
export const FEED_PATHS = [ FEED_PATH, ...Object.values(KIND_FEED_PATHS) ]

// The Rails app's article feeds, which took `?tag=` too
export const LEGACY_ARTICLE_FEED_PATHS = [ "/articles/atom", "/articles/rss" ]

// A feed's pages are built as <feed>/page/<n>, the first one included; the Worker answers
// the feed's own URL with its first page, since a file can't share a name with a folder
export function feedPagePath(feedPath: string, number: number) {
  return `${feedPath}/page/${number}`
}

// Where the Rails app's feed URLs go now, with their query strings dropped: the article feeds
// to /articles/feed, and `/feed?types=…&tag=…` with a single type to that type's feed. Any
// other /feed URL is the whole feed, so it doesn't move. Tags aren't filtered by any more.
export function legacyFeedPath(url: URL) {
  const types = (url.searchParams.get("types") ?? "").split(",").filter(type => type !== "")

  if (LEGACY_ARTICLE_FEED_PATHS.includes(url.pathname)) {
    return KIND_FEED_PATHS.article
  } else if (url.pathname === FEED_PATH && types.length === 1) {
    return KIND_FEED_PATHS[types[0]]
  }
}
