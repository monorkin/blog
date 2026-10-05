# Deployment

The site runs on Cloudflare Workers with static assets, as the Worker `blog`. Don't run
`bin/deploy` or `wrangler deploy` unless Stanko asks for exactly that.

## bin/deploy

```bash
bin/deploy
```

1. `bin/link-previews`, for the hover cards of links that don't have one, and
   `bin/media variants`, for new posters, variants and the manifest (`doc/images.md`).
2. It stops unless the tree is clean and the branch matches its upstream, neither ahead nor
   behind, so what goes live is what's in git. New cards or a changed manifest from step 1
   stop it here too: the build reads both from the repository, so they're committed first.
3. It checks wrangler is logged in to Cloudflare, with `wrangler whoami`, and offers to run
   `wrangler login` when it isn't. That way a deploy doesn't fail at the end with the media
   already synced. A `CLOUDFLARE_API_TOKEN` in the environment skips the check.
4. `bin/media sync`, which makes R2 match `media/`, and asks before deleting anything
   there (`doc/images.md`). A no stops the deploy. It purges whatever it replaced or deleted
   from Cloudflare's cache.
5. `npm run build`, then `npx wrangler deploy`.
6. It tells search engines what changed, through IndexNow (below).

## IndexNow

IndexNow lets Bing, Yandex and a few other search engines know a page changed, so they crawl
it again without waiting for the sitemap. Google doesn't use it.

```bash
bin/indexnow changed                      # URLs whose sitemap entry differs from the live site's
bin/indexnow all                          # every URL in the build's sitemaps
bin/indexnow all | bin/indexnow submit    # submit them all, after a change to every page
```

`changed` compares the sitemaps in `dist/client/` with the live ones: new URLs, removed
ones, and ones with a new `lastmod`. `bin/deploy` runs it after building but before
deploying, since after that the live sitemaps are the new ones, and submits the result once
the deploy is done. A change that doesn't move `lastmod`, like a new layout, isn't in it;
submit everything by hand for that.

The key is public by design: it's `public/<key>.txt`, holding the key itself, which proves
the site is ours. `bin/indexnow` reads it from there; changing it means renaming the file and
its contents together.

## What a deploy is

`npm run build` writes everything to `dist/`:

- `dist/client/` is the static assets: every page, the feeds, the Pagefind index,
  `/entry-paths.json`, `_redirects` and `_headers`.
- `dist/server/` is the Worker, which the `@astrojs/cloudflare` adapter builds from
  `src/worker.ts` (the adapter's handler, after the feed redirects), and
  `dist/server/wrangler.json`, the configuration wrangler deploys. The adapter points
  wrangler at it through `.wrangler/deploy/config.json`.

`wrangler.jsonc` at the root is the source of that configuration: the Worker's name, its
compatibility date, the `ASSETS` binding and how assets are served. Change it there.

The deploy itself is `npm run build && npx wrangler deploy`, the last step of `bin/deploy`.

## Media

Every image and video an entry shows is in an R2 bucket served at `MEDIA_URL`
(`doc/images.md`), not in the Worker's assets, which is why the build output is about 11 MB.
`bin/media sync` copies new originals and variants to the bucket, and has to run before a
deploy that uses them. The bucket is `stanko-io` on account
`968c9cb19aac8b4e00f9f3b62f75de4e`, served at `https://media.stanko.io`, which is
`MEDIA_URL`'s default in `astro.config.mjs`; a build can override it with the `MEDIA_URL`
environment variable.

The account and bucket are in `.mise.toml`. The R2 keys are in Stanko's personal 1Password
account (`my.1password.eu`), vault `Infrastructure`, item `stanko.io`, section
`media.stanko.io`, and `bin/media`
reads them with `op run` only when it syncs or pulls (`doc/images.md` has the details). A CI job sets `R2_ACCESS_KEY_ID`,
`R2_SECRET_ACCESS_KEY` and `CLOUDFLARE_CACHE_PURGE_TOKEN` itself and 1Password isn't involved.

## The domain

stanko.io is in Cloudflare, proxied to the server that ran the Rails app. The Worker takes
it over with a route in `wrangler.jsonc`, `stanko.io/*`, rather than a custom domain: the
DNS record stays, and removing the route and deploying again sends the domain back to the
server. `www.stanko.io` redirects to `stanko.io` before it gets here. media.stanko.io is R2's
custom domain and isn't touched. After the first deploy with the route, purge the stanko.io
cache in Cloudflare, so pages cached from the Rails app go.

The Worker is also at its `workers.dev` address, which `wrangler deploy` prints.
