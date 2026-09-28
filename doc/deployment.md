# Deployment

The site runs on Cloudflare Workers with static assets. **It hasn't been deployed.** Don't
run `bin/deploy` or `wrangler deploy` unless Stanko asks for exactly that.

## bin/deploy

```bash
bin/deploy
```

1. It stops unless the tree is clean and the branch matches its upstream, neither ahead nor
   behind, so what goes live is what's in git.
2. It checks wrangler is logged in to Cloudflare, with `wrangler whoami`, and offers to run
   `wrangler login` when it isn't. That way a deploy doesn't fail at the end with the media
   already synced. A `CLOUDFLARE_API_TOKEN` in the environment skips the check.
3. `bin/media variants`. If that changes anything, such as a new poster or the manifest, it
   stops and asks for a commit, because the build reads the manifest from the repository.
4. `bin/media sync`, which makes R2 match `media/`, and asks before deleting anything
   there (`doc/images.md`). A no stops the deploy.
5. `npm run build`, then `npx wrangler deploy`.

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
reads them with `op run` only when it syncs or pulls (`doc/images.md` has the details). A CI job sets `R2_ACCESS_KEY_ID` and
`R2_SECRET_ACCESS_KEY` itself and 1Password isn't involved.

## Scheduled posts

An entry with a future `publishedAt` is left out of the build until then
(`doc/content.md`), so something has to build and deploy once a day for scheduled posts to
appear. That job isn't set up yet. It needs to check out the repository, run
`npm ci && npm run build && npx wrangler deploy` with a Cloudflare API token. It doesn't need
the media: the build reads only the manifest.

## Before the switch

The Rails app still serves stanko.io. Moving the domain means pointing it at the Worker; DNS
isn't managed from here.
