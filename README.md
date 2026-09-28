# stanko.io

## Set up

```bash
bin/setup      # Installs all tools and dependencies
bin/media pull # Pull all assets locally - must be done before using `sync`, else chaos
```

## Development

```bash
bin/dev        # http://localhost:4321, reloads as you write
bin/preview    # http://localhost:8787, the production build, with search
```

## How to add

Use `bin/generate`.

It makes the entry's folder, named `<slug>-<id>`, with a fresh ID, plus a directory for
its media under `media/originals/`, and prints the file to edit and the URL it'll have.

> [!IMPORTANT]
> The folder name is the URL

Everything starts as a draft. To publish:

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

<Video media="demo.mp4" caption="The demo" />
```

- The first `<Figure>` is the image shown when the article is shared, so lead with a good one.
- A video's poster is the image with the same name beside it (`demo.jpg`). If there isn't
  one, `bin/media variants` takes a frame from the video. Put your own there to override it.
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
videoMirrorUrl: https://www.youtube.com/watch?v=...
```

For a recording, put `talk.mp4` in `media/originals/talks/<slug>-<id>/` and run
`bin/media variants`. It makes the poster, `talk.jpg`, from a frame a fifth of the way in.

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

For a video snap, use `video` instead of `image`. The poster and the length shown on the
grid come from the video. Then run `bin/media variants`, which also strips the GPS
location, and look at it in `bin/dev`.

## How to rename

```bash
bin/rename article 8s17uw9GPHgD "New title"
bin/rename 8s17uw9GPHgD "New title"   # the type is optional
```

The ID is the end of the folder name. This sets the title, moves the entry and its media to
`<new-slug>-<id>`, and updates the media keys. The old URL redirects to the new one, and feed
readers don't see it as a new post. If the entry has media, run `bin/media sync` afterwards.

## More

- `AGENTS.md` and `doc/` cover how everything works.
- `.agents/skills/` has the step-by-step versions of the above.
