# The feeds

Four static Atom feeds, built with the rest of the site, newest entry first:

| URL | Has |
|---|---|
| `/feed` | Everything |
| `/articles/feed` | Articles |
| `/talks/feed` | Talks |
| `/snaps/feed` | Snaps |

`src/lib/feed.ts` lists them (`FEEDS`) and renders them. A new entry is in its feeds after
the next build, like everywhere else.

Pages point feed readers at a feed with `<link rel="alternate">`: a section's pages
(`<Layout section="articles">` and so on) at that section's feed, everything else at
`/feed`. The prompt under each article links to `/articles/feed`.

## Pages

Each feed is paged as RFC 5005 describes: 50 entries a page (`FEED_PAGE_SIZE`), newest
first, and every page links to the `first`, `last`, `previous` and `next` ones, and to
itself. The first page is the feed's own URL, so subscribers see nothing change; later
pages are `/feed/page/2` and so on. A page past the last is a 404.

The pages are built as `<feed>/page/<n>`, the first one included, by
`src/pages/feed/page/[page].ts` and its siblings under `articles/`, `talks/` and `snaps/`.
The feed's own URL can't be a file too, because a file can't share its name with the
`page/` folder beside it, so the Worker answers it: `run_worker_first` in `wrangler.jsonc`
sends the four feed URLs to `src/worker.ts`, which serves `<feed>/page/1` in their place.
That leaves `/feed/page/1` answering as well, with the same document; nothing links to it.
`public/_headers` gives the pages their content type, since they have no extension.

The stylesheet shows "Newer" and "Older" links when a page has them.

## The Rails app's URLs

The Rails app had one feed that filtered by `?types=` and `?tag=`. People only ever filtered
by type, so tags are gone:

- `/feed?types=article` (one type, with or without a `tag`) redirects (301) to that type's
  feed.
- Any other `/feed?…`, several types, an unknown one, or only a `tag`, is the whole feed.
- `/articles/atom` and `/articles/rss` redirect to `/articles/feed`, dropping `?tag=`.
- `/feed/style` and `/articles/atom_style` redirect to `/feed.xsl`.

Static files can't redirect on a query string, and `_redirects` can't match or drop one, so
the Worker does it: `run_worker_first` sends `/articles/atom` and `/articles/rss` to it
too, and `src/worker.ts` redirects the old URLs (`legacyFeedPath` in
`src/lib/feed-paths.ts`). Every other URL is a static file first.

## The XML

It matches what the Rails app rendered, so feed readers see no change in the entries:

- The `<?xml-stylesheet href="/feed.xsl"?>` instruction, so a browser shows a page.
- Each feed has its own ID (`tag:stanko.io,2005:/articles/feed`), title and self link.
- Entry IDs are `tag:stanko.io,2005:<feedId>`, e.g. `tag:stanko.io,2005:Article/46`. Migrated
  entries carry `feedId` in their frontmatter; never change it (`doc/content.md`).
- The content is the entry's HTML in a `<div class="lexxy-content">`, with absolute URLs,
  the summary its 300-character excerpt, and the author Stanko Krtalic Rusendic.

`/feed.xsl` (`src/pages/feed.xsl.ts`) is the XSL stylesheet, built with the site's CSS. It
links to the four feeds.
