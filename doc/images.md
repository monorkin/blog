# Images and media

Two kinds of files, kept in two places:

- **Site assets** are part of the design: favicons, the portrait, the contact logos, the
  default Open Graph image, error page images. They're in git, in `public/` and
  `src/assets/images/`, and Astro handles them.
- **Media** is what entries show: article images and videos, snap photos, video posters,
  link preview images. None of it is in git. The originals live in R2, and locally in
  `media/originals/`, and the site links to them through `MEDIA_URL`.

## Keys and URLs

A piece of media is named by its key, its path under `media/originals/`:

```
articles/clean-air-ai-AHcddmIf21lt/img_8969.jpeg
snaps/soca-valley-C4wEfGoWTXNS/1000054880.jpg
link-previews/233-og-image.png
```

Entries use keys, never URLs (`doc/content.md`). The bucket, and `media/`, hold:

| Path | What |
|---|---|
| `originals/<key>` | The file as uploaded, for download and for anything without variants |
| `variants/<key>/<width>w.webp`, `.jpg`/`.png` | Resized to that width, in WebP and in the original's format |
| `variants/<key>/<size>sq.webp`, `.jpg`/`.png` | Cropped square: snap thumbnails (400, 800) and Open Graph images (512) |

The bucket is `stanko-io` on account `968c9cb19aac8b4e00f9f3b62f75de4e`, served at
`https://media.stanko.io`.

`MEDIA_URL` is set at build time. Production uses `https://media.stanko.io`, the bucket's
custom domain (`astro.config.mjs`). `bin/dev` uses `/media`, which `astro dev`
serves from `media/`; `bin/preview` uses `http://localhost:4322`, where `bin/media serve`
serves it. So both work offline.

## The manifest

`src/data/media.json` is in git and describes every original: its type, size in bytes,
width and height (rotation applied, for photos and videos), and which variants exist.
Components read it to write `srcset`, `width` and `height` without touching the files, which
is why the build doesn't need `media/`. A key missing from it fails the build.

## bin/media

```bash
bin/media variants          # make missing variants and rewrite src/data/media.json
bin/media sync --dry-run    # what would be copied to R2
bin/media sync              # copy media/originals and media/variants to R2
bin/media pull              # fetch the originals from R2 into media/originals
bin/media serve             # serve media/ on http://localhost:4322
```

`variants` reads `media/originals/` with sharp, only makes variants that are missing or older
than their original, removes variants whose original is gone, and rewrites the manifest
from scratch. Video sizes come from `ffprobe`, which `bin/setup` installs.

| Media | Widths | Squares |
|---|---|---|
| `link-previews/` | 400, 768 | |
| `snaps/` | 480, 800, 1200, 1600, 2400 | 400, 512, 800 |
| everything else | 480, 800, 1200, 1600, 2400 | 512 |

Only widths smaller than the original are made, plus the original's own width when it's
under 2400, so nothing is upscaled. GIFs and SVGs get no variants and are served as they are,
so animations keep playing. Videos are served as they are too.

`sync` only copies; it never deletes from the bucket, and uploads with a year-long
`Cache-Control`, so a changed file needs a new name.

**Syncing changes Cloudflare. Only do it when Stanko asks.**

### Credentials

`sync` and `pull` use rclone over R2's S3 API, configured from four variables:

| Variable | Comes from |
|---|---|
| `R2_ACCOUNT_ID` | `.mise.toml` `[env]`; not a secret |
| `R2_BUCKET` | `.mise.toml` `[env]`; not a secret |
| `R2_ACCESS_KEY_ID` | 1Password, through `.env.1password` |
| `R2_SECRET_ACCESS_KEY` | 1Password, through `.env.1password` |

When the two keys are already in the environment, as in CI, `sync` and `pull` use them.
Otherwise they run themselves again under
`op run --account my.1password.eu --env-file=.env.1password`, which resolves
the `op://` references in that file (it holds references only, never secrets) and passes the
keys to that one process. Nothing else asks 1Password: not `variants`, not `serve`, not
`sync --dry-run`, and not mise, which is why the keys aren't in `[env]` (every `cd` would
prompt). The 1Password CLI has to be 1Password's own package, with desktop app integration
turned on: on Linux the app only unlocks for that setgid binary, so mise can't provide it,
and `bin/setup` only checks it's there. `bin/media` always names the personal
account, `my.1password.eu`, because a work account is signed in beside it.

`sync --dry-run` without the keys lists what's local and doesn't contact the bucket. To see
exactly what rclone would copy, give it the keys:
`op run --account my.1password.eu --env-file=.env.1password -- bin/media sync --dry-run`.

The 1Password item the references point at:

| | |
|---|---|
| Account | `my.1password.eu` |
| Vault | `Infrastructure` |
| Item | `stanko.io` |
| Section | `media.stanko.io` |
| Fields | `Access Key ID` and `Secret Access Key` (the section's `url` and `token` aren't used) |

A reference is `op://Infrastructure/stanko.io/media.stanko.io/Access Key ID`. The item's
other sections hold the old Rails app's production secrets; `.env.1password` names only the
two R2 fields.

Create the token in Cloudflare under R2 → Manage API tokens, with Object Read & Write on the
`stanko-io` bucket.

At the migration: 554 originals (480 MiB) and 3,064 variants (366 MiB).

## How entries show it

`<Figure>` (`src/components/content/Figure.astro`) renders what the Rails app's attachment
partial did, with a `<picture>`: WebP variants first, the original's format as the fallback,
the size and `--attachment-width`/`--attachment-height` from the manifest, so nothing shifts
as images load.

- From 600px up, an image is as wide as the column, or its own width if that's smaller, at
  its own aspect ratio, however tall that makes it.
- Below 600px, a portrait image (`attachment--expandable`) is capped at 32rem tall, and
  tapping it toggles `attachment--expanded` to show it full size
  (`src/scripts/attachments.ts`).

`<Gallery>` puts its figures side by side, top-aligned. That's too small to read a
screenshot, so clicking one opens it full size in a lightbox, with arrows to move through the
gallery (`src/scripts/gallery.ts`).

`<Video>` renders an autoplaying, muted, looping video sized from the manifest, with its
poster's 1200px variant.

Snaps get square thumbnails for the grid, the width variants in the lightbox, and a link to
the original for download. Open Graph images are an entry's cover image's 512px square, or
`src/assets/images/default_seo_image.jpg`.

## Link previews

Hovering a link in an article shows a preview of the page it points to. The previews were
fetched by the Rails app and exported to `src/data/link-previews.json`, keyed by URL, with
their images as `link-previews/` media. Each article page embeds the previews for its own
links as JSON, and `src/scripts/link-previews.ts` shows them. Nothing is fetched at build
time.

## Size limits

Workers can't serve a static asset over 25 MiB, which is why media isn't a static asset. R2
has no such limit: the two largest originals, a 25.2 MiB photo and a 36.8 MiB video, are
ordinary media.
