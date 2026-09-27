# The feed

`/feed` is one Atom feed of every published entry, newest first, and the only page the
Worker renders.

## How it's made

At build time `src/pages/feed/entries.json.ts` writes `/feed/entries.json`: every published
entry with its feed ID, title, dates, tags, HTML content (with absolute URLs) and summary,
plus the list of known tags. At request time `src/pages/feed.ts` fetches that file from the
static assets, filters it and renders the XML with `src/lib/feed.ts`. So a new entry is in
the feed after the next build, like everywhere else.

## Filters

Both take comma-separated lists, with the same rules as the Rails app's `FeedController`:

- `?types=article,talk` keeps entries of those kinds (`article`, `talk`, `snap`).
- `?tag=ruby,go` keeps entries with any of those tags.
- Unknown values are dropped, and a filter with nothing valid left doesn't filter:
  `?tag=nonexistent` is the whole feed.

`/articles/rss` and `/articles/atom` are the old article feeds and redirect to
`/feed?types=article`, keeping `tag`.

## The XML

It matches what the Rails app rendered, so feed readers see no change:

- The `<?xml-stylesheet href="/feed/style"?>` instruction, so a browser shows a page.
- Entry IDs are `tag:stanko.io,2005:<feedId>`, e.g. `tag:stanko.io,2005:Article/46`. Migrated
  entries carry `feedId` in their frontmatter; never change it (`doc/content.md`).
- The content is the entry's HTML in a `<div class="lexxy-content">`, the summary its
  300-character excerpt, and the author Stanko Krtalic Rusendic.

`/feed/style` (`src/pages/feed/style.ts`) is the XSL stylesheet, built with the site's CSS
and the current list of tags to filter by.
