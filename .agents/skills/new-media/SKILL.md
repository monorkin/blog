---
name: new-media
description: Adding images and videos to an entry or project — putting originals in media/originals under a key, making variants and the manifest with bin/media, using the key in MDX or frontmatter, and syncing to R2 when asked. Use when an entry needs a photo, screenshot or video, when an image doesn't show, when src/data/media.json is out of date, or when R2 comes up.
---

# New media

Media never goes in git: not in `src/`, not in `public/`. `doc/images.md` explains the setup;
this is the procedure. (Site assets, the things the layout itself uses, are the exception and
stay in `src/assets/images/`.)

## 1. Put the original in media/originals/

Under the entry's folder name, so keys never collide:

```bash
mkdir -p media/originals/articles/clean-air-ai-AHcddmIf21lt
cp ~/Downloads/IMG_8969.jpeg media/originals/articles/clean-air-ai-AHcddmIf21lt/img_8969.jpeg
```

Name files in lowercase with dashes. The key is the path under `media/originals/`:
`articles/clean-air-ai-AHcddmIf21lt/img_8969.jpeg`.

Replacing a file? Give it a new name. R2 serves media with a year-long cache, so the old
file would linger in browsers under the old name.

No size limit applies here; a 40 MB video is fine.

## 2. Make the variants and the manifest

```bash
bin/media variants
```

It adds the file to `src/data/media.json` with its size and variants. Videos need `ffprobe`,
which `bin/setup` installs. The manifest change is the part that goes in git.

## 3. Use the key

An entry names its own media by file name; the components look it up in the entry's media
folder, and need no import. In MDX:

```mdx
<Figure media="img_8969.jpeg" caption="Zagreb from Sljeme" />

<Video media="demo.mp4" poster="demo.jpg" type="video/mp4" caption="The demo" />
```

A video needs a poster image beside it; grab a frame with
`ffmpeg -i demo.mp4 -frames:v 1 demo.jpg`.

In a snap's frontmatter: `image: <file>`, or `video`, `videoType` and `poster` for a video
snap.

Another entry's media takes its full key, the path under `media/originals/`:
`<Figure media="snaps/soca-valley-C4wEfGoWTXNS/1000054880.jpg" />`.

## 4. Look at it

`bin/dev` or `bin/preview` serve `media/` locally, so the new image shows without R2. Check
it at 390px and at desktop width.

## 5. Sync to R2

**Only when Stanko asks**: it changes Cloudflare. First see what would go up:

```bash
bin/media sync --dry-run
```

That lists what's local and doesn't touch 1Password or the bucket. To compare with the
bucket, `op run --account my.1password.eu --env-file=.env.1password -- bin/media sync --dry-run`.

Then `bin/media sync`. The account and bucket come from `.mise.toml`; the keys come from
1Password: `sync` reruns itself under `op run --account my.1password.eu`, which reads the
`Infrastructure` vault's `stanko.io` item, section `media.stanko.io`, fields
`Access Key ID` and `Secret Access Key`
(`.env.1password` has the references). 1Password may ask Stanko to approve with a biometric
prompt. If the item can't be read, stop and tell Stanko; don't work around it, and never
print a secret to check it.
When `R2_ACCESS_KEY_ID` and `R2_SECRET_ACCESS_KEY` are already set, as in CI, they're used
as they are. Never put the keys in a file or in `.mise.toml`.

It only copies, never deletes. The media has to be in R2 before a deploy that uses it.

## On a new machine

`media/` is empty after a clone. `bin/media pull` fetches the originals from R2, with the
keys from 1Password the same way, then `bin/media variants` makes the variants.
