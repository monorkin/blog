# Blog -- Agent instructions

Stanko's personal blog at stanko.io: articles, talks, snaps (photos) and projects. A static
[Astro](https://astro.build) site on Cloudflare Workers, where every page is built ahead of
time, the Atom feeds included, and one Worker answers a few redirects.

It used to be a Rails app, which is this repository's history. The content was exported
from it once, and the URLs, markup and CSS were kept as they were.

## Read before you touch

| Subject | Read |
|---|---|
| The collections, the frontmatter, MDX components, drafts and scheduling, the one-off export from Rails | `doc/content.md` |
| Every URL the site answers, pagination, redirects, the slug lookup, sitemaps | `doc/routes.md` |
| The Atom feeds, the old feed URLs and the stylesheet | `doc/feed.md` |
| Images and videos: media keys, the manifest, `bin/media`, R2, link previews | `doc/images.md` |
| The layout, CSS, scripts, color scheme, search and the dialogs | `doc/front-end.md` |
| Cloudflare, wrangler, R2 and the scheduled rebuild | `doc/deployment.md` |
| Setting up, `bin/dev`, `bin/preview`, and checking your work | `doc/development.md` |
| Style: any code | `STYLE.md` (below) |
| Skills: `new-entry`, `new-project-page`, `new-media` | `.agents/skills/` |

Read what matches what you're editing, not all of it.

## Hard rules

1. **URLs don't change.** Articles are `/:slug-:id`, talks `/talks/:slug-:id`, snaps
   `/snaps/:slug-:id`, tags `/tags/:name`. Links to them are all over the internet and in
   feed readers. A new route must not shadow an old one; `doc/routes.md` lists them all.
2. **The ID in a slug is the entry.** An entry's folder name is its URL; never rename one
   that is published. A new entry gets a new random ID (`doc/content.md`).
3. **Feed IDs are forever.** `feedId` in migrated frontmatter keeps Atom entry IDs as the
   Rails app made them, so feed readers don't show old posts as new. Don't edit or remove it.
4. **Media stays out of git.** Photos, screenshots and videos go in `media/originals/` and R2,
   and entries refer to them by key; only `src/data/media.json` is committed (`new-media`
   skill). Git holds site assets only: favicons, the portrait, logos.
5. **Never deploy.** No `wrangler deploy`, no `bin/media sync`, no changes to Cloudflare, R2
   or DNS, unless Stanko asks for exactly that. `bin/dev` and `bin/preview` are the ways to
   run it.
6. **No framework in the browser.** Astro components and small scripts in `src/scripts/`.
   Keep the look: the CSS in `src/styles/` came from the Rails app and is the reference.

## Check before you hand back

```bash
npm run check    # astro check: types in .astro and .ts files
npm run build    # the whole site, then the Pagefind index
```

Both must pass without errors. For anything that renders, look at it in `bin/preview`, and
for layout changes check a phone width (390px) as well as a desktop one.
`doc/development.md` has more ways to check a change.

## Leave the place tidy

Update this file and the page under `doc/` that covers what you changed, in the same change.
Keep each page about one subject, so reading the one that matters doesn't drag in four that
don't.

## Running it

```bash
bin/setup     # once: mise tools, ffmpeg, npm packages; then bin/media pull && bin/media variants
bin/dev       # astro dev with hot reload; bin/preview builds and serves it as production does
```

`doc/development.md` is the rest.

@STYLE.md
