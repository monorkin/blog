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

Entries use keys, never URLs (`doc/content.md`), and name their own media by file name
alone: `img_8969.jpeg` in `articles/clean-air-ai-AHcddmIf21lt` is
`articles/clean-air-ai-AHcddmIf21lt/img_8969.jpeg`. `resolveMediaKey` in `src/lib/media.ts`
does that; a key with a slash is taken as complete. Rendered entries pass their folder to
the components as `Astro.locals.mediaFolder`, and a project page's folder is its URL, e.g.
`projects/air-quality-box`.

The bucket, and `media/`, hold:

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

Each resizable image (JPEG, PNG, WebP; not GIFs, SVGs or videos) also has a `placeholder`,
a WebP data URI no longer than 16px, and `color`, its average as a hex string. They make up
about 95 KB of the manifest's 240 KB, and add about 0.8 KB to the page per image shown.

## Placeholders

While an image loads, its box shows a blurred version of it over its average color instead of
a gap. `placeholderStyle(key)` in `src/lib/media.ts` turns the manifest's tiny image into an
SVG that blurs it (and keeps the blurred edges opaque) and returns it as custom properties;
the `placeholder` class (`src/styles/components/placeholder.css`) paints them as a
background. Give the class and the style to the element whose box is the image's:

- a box around the image, like `<Figure>`'s `<picture>` or a snap thumbnail's link: the
  image fades in over it in 0.2s, once `src/scripts/placeholders.ts` marks it loaded
- the image or video itself, like a snap in the lightbox or a video's poster: the image
  just covers it

Until then a band of light sweeps across the placeholder every 1.6s, so it reads as loading
rather than as a blurry picture. It's a third background layer rather than a spinner or a
pseudo-element, because the placeholder can be on the `<img>` itself, which can't have one.

Without JavaScript, or with reduced motion, there's no fade and no sweep; the image covers
the placeholder as it loads. Once loaded, the placeholder goes, so nothing shows through
transparent parts.

## bin/media

```bash
bin/media variants          # make missing variants and rewrite src/data/media.json
bin/media sync --dry-run    # what would be copied to and deleted from R2
bin/media sync              # make R2 match media/originals and media/variants
bin/media pull              # fetch the originals from R2 into media/originals
bin/media serve             # serve media/ on http://localhost:4322
```

`variants` first makes a poster for any video without one: the image beside it with the
same name, e.g. `demo.jpg` for `demo.mp4`, which is where the site looks for a video's
poster. It's taken a fifth of the way in, past a black or title-card opening, as the best of
the next 150 frames by ffmpeg's `thumbnail` filter. A poster that's already there is left
alone, so replacing a bad frame means putting a better image there under the same name.
It then strips each original's metadata in place (below), then reads
`media/originals/` with sharp, only makes variants that are missing or older than their
original, removes variants whose original is gone, and rewrites the manifest from scratch. It makes each placeholder from the smallest variant and keeps the previous
one while the original's size hasn't changed. Video sizes and lengths (`duration`, in whole
seconds) come from `ffprobe`, which `bin/setup` installs.

`bin/dev` runs `variants` itself whenever something in `media/originals/` is added, changed
or removed, a second after the last change, so a new photo shows on the next reload. Its
output goes to the dev server's log. `bin/preview` and the build don't; run it by hand there.

| Media | Widths | Squares |
|---|---|---|
| `link-previews/` | 400, 768 | |
| `snaps/` | 480, 800, 1200, 1600, 2400 | 400, 512, 800 |
| everything else | 480, 800, 1200, 1600, 2400 | 512 |

Only widths smaller than the original are made, plus the original's own width when it's
under 2400, so nothing is upscaled. GIFs and SVGs get no variants and are served as they are,
so animations keep playing. Videos are served as they are too: there are no smaller
versions, so a phone gets the full file. A talk's recording (`talks/<folder>/talk.mp4`, up
to 330 MB at 1080p) plays with `preload="none"`, so nothing downloads until someone
presses play, and then the browser fetches it in ranges as it plays. A video must have its
index (the `moov` atom) at the front to start before it has all downloaded; ffmpeg's
`-movflags +faststart` puts it there, and the remux that strips metadata keeps it there.

`sync` makes the bucket's `originals/` and `variants/` match `media/`: it uploads what's new
or changed, and deletes what's gone locally, such as a renamed entry's old keys or a
removed image's variants. It compares files by size and checksum, not modification time,
and uploads with a year-long `Cache-Control`.

So Cloudflare doesn't go on serving the old version of a file for that year, `sync` then
purges from its cache the URL of every file it replaced or deleted: rclone's `--combined`
report names them, and `sync` sends them to Cloudflare's purge API, 30 at a time. Should
the purge fail, it prints the URLs it didn't purge, because the next sync won't see those
files as changed. `sync --dry-run` lists the URLs it would purge. Browsers that already
have a file keep their copy until it expires.

A machine that hasn't pulled every original would empty the bucket that way, so `sync`
lists the bucket first. When anything would be deleted, it shows as many of those files as
fit on the screen, says how many there are in all, and deletes only after you type `yes`.
Without a terminal to ask in, it refuses. `--max-delete` caps the deletions at the count it
asked about. `sync --dry-run` shows the same list without asking. Under `op run` it passes
`--no-masking`, so the question reaches the terminal.

### Metadata

Originals are public on R2, and a photo or video straight off a phone carries where it was
taken, the camera or phone and its serial number, and when. The variants never had any
(sharp drops it), but the originals did, so `bin/media variants` strips them in place
before anything else, without re-encoding:

- Images (JPEG, PNG, WebP): exiv2 removes all EXIF, XMP and IPTC data and comments, maker
  notes and thumbnails included, then puts back the orientation tag, so nothing turns
  sideways. The colour profile stays; the pixels don't change.
- Videos: ffmpeg remuxes them without container, stream or chapter metadata (location,
  make, model, software, creation time). The rotation is kept; the frames are copied.

A stripped file keeps its modification time, so its variants aren't made again. GIFs and
SVGs aren't touched; neither had any.

`bin/media sync` checks every original first and refuses to upload one that still has GPS
or location data, naming it. Run `bin/media variants`, then sync again.

**Syncing changes Cloudflare. Only do it when Stanko asks.**

### Credentials

`sync` and `pull` use rclone over R2's S3 API, configured from four variables:

| Variable | Comes from |
|---|---|
| `R2_ACCOUNT_ID` | `.mise.toml` `[env]`; not a secret |
| `R2_BUCKET` | `.mise.toml` `[env]`; not a secret |
| `R2_ACCESS_KEY_ID` | 1Password, through `.env.1password` |
| `R2_SECRET_ACCESS_KEY` | 1Password, through `.env.1password` |

`sync` also needs `CLOUDFLARE_CACHE_PURGE_TOKEN`, from 1Password the same way, to purge
Cloudflare's cache.

When the keys are already in the environment, as in CI, `sync` and `pull` use them.
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
| Fields | `Access Key ID`, `Secret Access Key` and `Cache Purge Token` (the section's `url` and `token` aren't used) |

A reference is `op://Infrastructure/stanko.io/media.stanko.io/Access Key ID`. The item's
other sections hold the old Rails app's production secrets; `.env.1password` names only the
three fields `bin/media` uses.

Create the R2 keys in Cloudflare under R2 → Manage API tokens, with Object Read & Write on
the `stanko-io` bucket. Create the purge token under My Profile → API Tokens, as a custom
token with Zone → Zone → Read and Zone → Cache Purge → Purge, for the `stanko.io` zone
only. `sync` finds the zone's ID with it by name.

At the migration: 554 originals (480 MiB) and 3,064 variants (366 MiB).

## How entries show it

`<Figure>` (`src/components/content/Figure.astro`) renders what the Rails app's attachment
partial did, with a `<picture>`: WebP variants first, the original's format as the fallback,
the size and `--attachment-width`/`--attachment-height` from the manifest, so nothing shifts
as images load.

The `<img>`'s plain `src`, and any single image URL a page uses (`variantAtLeast`), is a
WebP variant whatever the original's format. Browsers pick from the `srcset`, but crawlers
like Ahrefs judge a page by its `src`, and a PNG screenshot at 1200px can be over 2 MB where
the WebP is 300 KB. For the same reason a snap's `src` is its 1200px variant, the largest
that stays under a megabyte.

- From 600px up, an image is as wide as the column, or its own width if that's smaller, at
  its own aspect ratio, however tall that makes it.
- Below 600px, a portrait image (`attachment--expandable`) is capped at 32rem tall, and
  tapping it toggles `attachment--expanded` to show it full size
  (`src/scripts/attachments.ts`).

`<Gallery>` puts its figures side by side, top-aligned. That's too small to read a
screenshot, so clicking one opens it full size in a lightbox, with arrows to move through the
gallery (`src/scripts/gallery.ts`).

`<Video>` renders an autoplaying, muted, looping video sized from the manifest the way an
image is, with its poster's 1200px variant and the poster's placeholder. The poster is the
image beside the video with the same name (`posterFor` in `src/lib/media.ts`), unless
`poster` names another, and the type comes from the manifest unless `type` is given. With `clip` it has no controls, for a short clip that stands in for a
GIF; convert GIFs to MP4 rather than adding them, since a GIF is many times bigger:

```bash
ffmpeg -i clip.gif -an -c:v libx264 -crf 23 -preset slow -pix_fmt yuv420p \
  -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -movflags +faststart clip.mp4
ffmpeg -i clip.mp4 -frames:v 1 -q:v 3 clip.jpg
```

Snaps get square thumbnails for the grid, the width variants in the lightbox, and a link to
the original for download. That link is `rel="nofollow"`, though Ahrefs follows it anyway
and reports originals of up to 26 MB as oversized images; its Site Audit project excludes
`media.stanko.io/originals/` from the crawl for that. The Rails app never saw this because
its images lived on Scaleway's domain, which Ahrefs counted as external. An entry's Open Graph image is its `ogImage`'s 512px square, a
snap's photo, or a generated preview card (`doc/content.md`). Pages that aren't entries use
`src/assets/images/default_seo_image.jpg`.

## Link previews

Hovering a link in an article shows a preview of the page it points to. The previews are in
`src/data/link-previews.json`, keyed by URL, with their images as `link-previews/` media.
Each article page embeds the previews for its own links as JSON, and
`src/scripts/link-previews.ts` shows them. Nothing is fetched at build time.

The Rails app fetched the first ones. `bin/link-previews` fetches the rest: for every link in
an entry's Markdown without a preview, it reads the page's title, description and Open Graph
image, and saves the image as `link-previews/<hash of the URL>-<image name>`. Only JPEG,
PNG and WebP images are kept, since a card needs the image's size from the manifest. A page
that won't load, or has no title, gets no card and is tried again on the next run; a few
sites, like Medium and Forbes, refuse it every time. Run `bin/media variants` after it, and
commit the JSON with the manifest.

## Size limits

Workers can't serve a static asset over 25 MiB, which is why media isn't a static asset. R2
has no such limit: the two largest originals, a 25.2 MiB photo and a 36.8 MiB video, are
ordinary media.
