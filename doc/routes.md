# Routes and URLs

Every URL the Rails app served still answers, with the same path. Most are static files
built ahead of time; a few are answered by the Worker.

The build uses `build.format: "file"` and `trailingSlash: "never"`, so `/articles` is
`dist/client/articles.html` and is served without a redirect.

## Pages

| URL | File | Notes |
|---|---|---|
| `/` | `src/pages/index.astro` | About, with the three latest articles |
| `/articles`, `/articles/page/N` | `src/pages/articles/[...page].astro` | |
| `/:slug-:id` | `src/pages/[article].astro` | An article |
| `/talks` | `src/pages/talks/index.astro` | All of them, sorted by when they were held; `/talks/page/N` redirects here |
| `/talks/:slug-:id` | `src/pages/talks/[talk].astro` | |
| `/snaps`, `/snaps/page/N` | `src/pages/snaps/[...page].astro` | Clicking opens the lightbox |
| `/snaps/:slug-:id` | `src/pages/snaps/[snap].astro` | Also what the lightbox loads |
| `/tags/:name`, `/tags/:name/page/N` | `src/pages/tags/[name]/[...page].astro` | |
| `/projects`, `/projects/:name` | `src/pages/_projects/` | Switched off: not built, so they 404 (below) |
| `/search`, `/settings` | `src/pages/search.astro`, `settings.astro` | The dialogs as pages, not indexed |
| `/:slug-:id.md`, `/talks/:slug-:id.md`, `/snaps/:slug-:id.md` | `src/pages/[article].md.ts`, `talks/[talk].md.ts`, `snaps/[snap].md.ts` | The entry as Markdown (below) |
| `/llms.txt` | `src/pages/llms.txt.ts` | The site for language models (below) |
| `/up` | `src/pages/up.ts` | Health check, kept from Rails |
| `/404.html` etc. | `public/` | The Rails app's error pages |

### Projects are switched off

The project pages are in `src/pages/_projects/`, and Astro doesn't route a folder whose
name starts with `_`: `/projects` and every project page 404, and the header, the menu and
the sitemap leave them out (`PROJECTS_ENABLED` in `src/lib/site.ts` follows the folder's
name). To switch them on, rename the folder to `src/pages/projects/`.

### Markdown and llms.txt

Every published entry is also Markdown at its URL plus `.md`, served as `text/markdown`
(`src/lib/markdown.ts`). It starts with YAML frontmatter: title, URL, author, dates, tags,
and for a talk its event, kind, date, video and mirror. Then comes the title as a heading,
and the body as written, with the MDX components turned into plain Markdown:
- a `<Figure>` becomes an image of its 1600px variant, with the caption as alt text;
- a `<Video>` becomes a link to the file;
- a `<Gallery>` is just its figures;
- a root-relative link becomes absolute.

A snap is its photo, or a link to its video, and its caption. Each entry's page points to
its Markdown with `<link rel="alternate" type="text/markdown">`. An old slug redirects the
`.md` too.

`/llms.txt` follows [llmstxt.org](https://llmstxt.org): a heading, a one-line summary, then
every article with its excerpt, every talk with its event and date, and the snaps under
`## Optional`, all linking to their Markdown versions.

### Pagination

Articles, snaps and tag pages show 12 entries a page and load the next page as you scroll,
or when "Load more" is clicked (`doc/front-end.md`). Talks aren't paginated.
Later pages are `/<index>/page/N`, not `/<index>/N`: `/talks/2` is an old talk URL that still
redirects. The Rails app paginated with `?page=N`; those URLs still answer, with the first
page, because static files ignore the query string.

The feeds, `/feed`, `/articles/feed`, `/talks/feed` and `/snaps/feed`, are built too, and
paged: `/feed/page/2` and so on (`doc/feed.md`).

## The Worker

Static files answer first, except for the paths `run_worker_first` in `wrangler.jsonc`
sends to the Worker, whose entry is `src/worker.ts`:

| URL | File | What |
|---|---|---|
| `/feed`, `/articles/feed`, `/talks/feed`, `/snaps/feed` | `src/worker.ts` | The built first page, `<feed>/page/1` |
| `/feed?types=X` | `src/worker.ts` | 301 to `X`'s feed when there's exactly one type; otherwise the whole feed |
| `/articles/rss`, `/articles/atom` | `src/worker.ts` | 301 to `/articles/feed`, dropping `?tag=` |
| anything that isn't a file | `src/pages/[...path].ts` | Slug redirects, then 404 (`prerender = false`) |

The catch-all looks an unknown path up by the ID at the end of its last segment, in
`/entry-paths.json`, which the build writes:
`/old-title-AHcddmIf21lt`, `/AHcddmIf21lt` and `/talks/whatever-uM1SflOFpRUk` all redirect
(301) to the entry's current URL, as the Rails app found entries by ID alone. Anything else
gets `public/404.html` with a 404.

## Redirects and headers

`public/_redirects` holds the static redirects: `/feed/style` and `/articles/atom_style`
to `/feed.xsl`, the numeric talk URLs (`/talks/1` to `/talks/15`, and `/talks/1050011312`)
the Rails app redirected, and `/talks/page/*` to `/talks`, from when talks were paginated.
Those IDs are frozen; new talks don't get one.

`public/_headers` gives the feeds' pages, `/feed.xsl` and `/up` their content types, since
the extension doesn't say it. The adapter adds long cache headers for `/_astro/*` to it at
build time.

Workers serves `/404.html` and the other error pages with a 307 to `/404` and so on.

## Sitemaps

`/sitemap.xml` is an index of `/sitemap-pages.xml`, `-articles`, `-talks`, `-tags` and
`-snaps`, each in `src/pages/`. A new kind of public page needs a place in one of them.
`/robots.txt` is in `public/`.
