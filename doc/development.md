# Development

How to run the site on your own machine and check a change.

```bash
bin/setup                  # once, and again whenever it's been a while: mise tools, ffmpeg, npm packages
bin/media pull             # once per machine: the media originals from R2 (keys from 1Password)
bin/media variants         # and their variants
bin/dev                    # astro dev at http://localhost:4321, reloading as you save
bin/preview                # npm run build, then wrangler dev at http://localhost:8787
bin/preview --skip-build   # serve the last build again
bin/generate article "Title"   # a new article, talk, snap or project (doc/content.md)
bin/link-previews          # hover cards for links that don't have one (doc/images.md)
```

## bin/setup

Installs what `.mise.toml` pins: Node, gum, rclone and gitleaks, and ffmpeg and exiv2 as system
packages (`[bootstrap.packages]`, for reading video sizes and stripping metadata from
originals), then the npm packages. Astro, wrangler, sharp and
Pagefind are npm packages, so their versions are in `package.json` and `package-lock.json`,
not in mise. On a machine without `node_modules` it runs `npm ci`, so it gets exactly the
lockfile; after that `npm install`, which does nothing when nothing changed. It is safe to
run as often as you like.

It needs [mise](https://mise.jdx.dev). Installing ffmpeg may ask for your password. It also
checks for the 1Password CLI, which `bin/media sync` and `pull` need and which has to come
from 1Password's own package, not mise (`doc/images.md` says why).

It also points git at `.githooks/`, whose pre-commit hook runs gitleaks over the staged
changes. The repository is public, so a commit with a secret in it stops there. gitleaks
never prints the secret, only the rule and the file. A false positive goes in
`.gitleaks.toml`, like the Ahrefs site key already there. To scan the whole history:
`mise exec -- gitleaks git --log-opts="--all" --redact`.

`bin/setup --quiet` prints nothing when all is well and the full output of a failed step
when it isn't. `bin/dev` and `bin/preview` run it that way every time. Either way it warns
when `media/` is missing, because pages then build with images that point at nothing.

## Media

Uploaded images and videos aren't in git (`doc/images.md`). `media/originals/` holds them
locally and `bin/media variants` makes `media/variants/` and `src/data/media.json` from
them. On a new machine, `bin/media pull` fetches the originals from R2 first. The account and
bucket come from `.mise.toml`, and the keys from 1Password through `op run`, which asks you
to approve in the 1Password app; `doc/images.md` has the item it reads.

Both `bin/dev` and `bin/preview` serve `media/` themselves, so nothing needs R2 or the
network while you work.

## bin/dev

`astro dev` with hot reload, with `MEDIA_URL=/media`: an integration in `astro.config.mjs`
serves `media/` there and runs `bin/media variants` when `media/originals/` changes
(`doc/images.md`). Arguments go to `astro dev`, e.g. `bin/dev --port 3000`.

The Cloudflare adapter runs the dev server inside workerd, so the on-demand routes work
here: `/feed` with its filters, `/articles/rss`, and the slug redirects. Content, styles and
the manifest reload as you save.

**Search doesn't work in `bin/dev`.** Pagefind indexes the finished HTML, which only exists
after a build, so the search box says to use `bin/preview`.

When Astro isn't attached to a terminal (an agent's shell, for example) it starts the dev
server in the background and returns. `npx astro dev status`, `npx astro dev logs` and
`npx astro dev stop` manage it.

## bin/preview

Runs `npm run build` (`astro build`, then `pagefind --site dist/client`) with
`MEDIA_URL=http://localhost:4322`, starts `bin/media serve` on that port, and serves the
build with `wrangler dev`, which is how Cloudflare runs it: files from `dist/client` first,
`_redirects` and `_headers` applied, and the Worker only for what isn't a file. This is the
closest thing to production and the only mode with search. Stopping it stops the media
server too.

A plain `npm run build` uses the production `MEDIA_URL`, which is what a deploy needs.

Nothing reloads; run it again after a change. Arguments go to `wrangler dev`, e.g.
`bin/preview --port 3000`.

If port 8787 is still taken after stopping it, a `workerd` process outlived wrangler; stop
that process.

## Checking a change

```bash
npm run check   # types
npm run build   # everything builds; a media key missing from the manifest fails it
```

For pages, open them in `bin/preview`. Things worth checking by hand after a front-end
change: the search dialog (Ctrl/Cmd+K), the settings dialog and color schemes, the phone
menu below 600px, "Load more" on /articles, a tall image in an article at both widths
(tapping it expands it on a phone), a gallery's lightbox, hovering a link in an article for
its preview, and the snap lightbox with the arrow keys.

Layout shift matters here: every image and video has its size set before it loads, from
the manifest. Keep it that way when touching `src/components/content/`.

## Where things are

| Path | What |
|---|---|
| `src/content/` | Articles, talks and snaps, one folder each (`doc/content.md`) |
| `src/pages/` | Routes (`doc/routes.md`) |
| `src/components/` | Layout pieces; `content/` holds the MDX components |
| `src/layouts/` | The page layout and the project page layout |
| `src/lib/` | Entries, tags, media, pagination, plain text, feed, sitemaps, site constants |
| `src/scripts/` | The browser scripts (`doc/front-end.md`) |
| `src/styles/` | The CSS, `app.css` imports it all |
| `src/data/` | Tags, link previews and the media manifest |
| `public/` | Favicons, error pages, `_redirects`, `_headers` |
| `bin/` | `setup`, `dev`, `preview`, `media`, `generate` |
| `lib/` | Node code the scripts and the Astro config share |
| `media/` | Uploaded media, not in git (`doc/images.md`) |
