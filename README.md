# stanko.io

My blog: articles, talks and snaps. A static Astro site on Cloudflare, with photos and
videos in R2 at media.stanko.io.

```bash
bin/setup     # once
bin/dev       # http://localhost:4321, reloads as you write
bin/preview   # http://localhost:8787, the production build, with search
```

## How to add

Every entry starts with `bin/generate`. It makes the entry's folder, named `<slug>-<id>`,
with a fresh ID, plus a folder for its media under `media/originals/`, and prints the file
to edit and the URL it'll have. The folder name is the URL, so get the title right before
publishing. If it's wrong, delete the folder and generate again.

Everything starts as a draft, which isn't built at all. To publish:

1. Remove `draft: true`, and set `publishedAt` to when it goes out. A future date schedules it
   for the first build after then.
2. `bin/media variants` if you added photos or videos, then commit, including
   `src/data/media.json`.
3. `bin/media sync` to upload the media to R2.
4. Deploy. That isn't set up yet; it'll be `npm run build && npx wrangler deploy`.

### An article

```bash
bin/generate article "Clean air & AI"
```

Write it in `src/content/articles/<slug>-<id>/index.mdx`, in Markdown:

```yaml
---
title: "Clean air & AI"
publishedAt: '2026-10-01T07:00:00Z'
updatedAt: '2026-10-01T07:00:00Z'
tags: [ruby, rails]
draft: true
---
```

Photos go in `media/originals/articles/<slug>-<id>/`, and the body refers to them by file
name, with no imports:

```mdx
<Figure media="view.jpeg" caption="Zagreb from Sljeme" />

<Gallery>
  <Figure media="one.jpeg" inGallery />
  <Figure media="two.jpeg" inGallery />
</Gallery>

<Video media="demo.mp4" poster="demo.jpg" type="video/mp4" caption="The demo" />
```

- The first `<Figure>` is the image shown when the article is shared, so lead with a good one.
- A GIF goes in as an MP4 with `clip` on its `<Video>`: it loops without controls.
- `bin/media variants` makes the resized copies and strips location data from the originals.
  Run it after adding media.
- Bump `updatedAt` when you edit a published article.

### A talk

```bash
bin/generate talk "Deconstructing Action Cable"
```

In `src/content/talks/<slug>-<id>/index.mdx`, replace the placeholder `event` and `heldAt`,
and set `kind` to `conference` or `meetup`. The body is the abstract.

```yaml
event: RubyZG meetup
kind: meetup
eventUrl: https://www.meetup.com/rubyzg/events/313063040/
heldAt: 2026-02-12T18:00:00Z
video: talk.mp4
poster: poster.jpg
videoMirrorUrl: https://www.youtube.com/watch?v=...
```

For a recording, put `talk.mp4` in `media/originals/talks/<slug>-<id>/`, along with a poster
taken from a frame of the talk rather than the black first one:

```bash
ffmpeg -ss 300 -i talk.mp4 -vf thumbnail=150 -frames:v 1 -q:v 3 poster.jpg
```

A YouTube copy goes in `videoMirrorUrl` and shows up as "View via mirror". With only a
YouTube link and no file, the page embeds YouTube instead. Either one gets the talk a VIDEO
label.

### A snap

```bash
bin/generate snap "Soca Valley" ~/Pictures/soca.jpg
```

That copies the photo into the snap's media folder and sets `image` for you. A snap has no
body, just frontmatter in `src/content/snaps/<slug>-<id>/index.md`, with an optional
`caption`:

```yaml
image: soca.jpg
caption: Morning fog over the valley
```

For a video snap, use `video`, `videoType` and `poster` instead of `image`. Then run
`bin/media variants`, which also strips the photo's GPS location, and look at it in `bin/dev`.

## More

- `AGENTS.md` and `doc/` cover how everything works.
- `.agents/skills/` has the step-by-step versions of the above.
