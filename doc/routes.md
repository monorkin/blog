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
| `/up` | `src/pages/up.ts` | Health check, kept from Rails |
| `/404.html` etc. | `public/` | The Rails app's error pages |

### Projects are switched off

The project pages are in `src/pages/_projects/`, and Astro doesn't route a folder whose
name starts with `_`: `/projects` and every project page 404, and the header, the menu and
the sitemap leave them out (`PROJECTS_ENABLED` in `src/lib/site.ts` follows the folder's
name). To switch them on, rename the folder to `src/pages/projects/`.

### Pagination

Articles, snaps and tag pages show 12 entries a page and load the next page as you scroll,
or when "Load more" is clicked (`doc/front-end.md`). Talks aren't paginated.
Later pages are `/<index>/page/N`, not `/<index>/N`: `/talks/2` is an old talk URL that still
redirects. The Rails app paginated with `?page=N`; those URLs still answer, with the first
page, because static files ignore the query string.

## The Worker

These are rendered on request (`export const prerender = false`):

| URL | File | What |
|---|---|---|
| `/feed` | `src/pages/feed.ts` | The Atom feed, `doc/feed.md` |
| `/articles/rss`, `/articles/atom` | `src/pages/articles/rss.ts`, `atom.ts` | 301 to `/feed?types=article`, keeping `?tag=` |
| anything else | `src/pages/[...path].ts` | Slug redirects, then 404 |

The catch-all looks an unknown path up by the ID at the end of its last segment:
`/old-title-AHcddmIf21lt`, `/AHcddmIf21lt` and `/talks/whatever-uM1SflOFpRUk` all redirect
(301) to the entry's current URL, as the Rails app found entries by ID alone. Anything else
gets `public/404.html` with a 404.

## Redirects and headers

`public/_redirects` holds the static redirects: `/articles/atom_style` to `/feed/style`,
the numeric talk URLs (`/talks/1` to `/talks/15`, and `/talks/1050011312`) the Rails app
redirected, and `/talks/page/*` to `/talks`, from when talks were paginated. Those IDs are
frozen; new talks don't get one.

`public/_headers` gives `/feed/style` and `/up` their content types, since neither has an
extension. The adapter adds long cache headers for `/_astro/*` to it at build time.

Workers serves `/404.html` and the other error pages with a 307 to `/404` and so on.

## Sitemaps

`/sitemap.xml` is an index of `/sitemap-pages.xml`, `-articles`, `-talks`, `-tags` and
`-snaps`, each in `src/pages/`. A new kind of public page needs a place in one of them.
`/robots.txt` is in `public/`.
