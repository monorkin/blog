---
name: new-entry
description: Adding a new article, talk or snap to the blog — the folder and its random ID, the frontmatter, images and videos through the MDX components, drafts and scheduling, and checking it before handing back. Use when asked to write, add, import or schedule a post, talk or photo.
---

# A new entry

`doc/content.md` is the reference for everything below; read it if a step is unclear.

## 1. Name the folder

The folder's name is the URL, and it never changes once published, so choose it once:

```bash
node -e 'const a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";console.log(Array.from(crypto.getRandomValues(new Uint8Array(12)),b=>a[b%62]).join(""))'
```

That's the ID. The slug is the title, lowercased, with runs of anything that isn't a letter
or digit turned into one dash: "Clean air & AI" is `clean-air-ai`. Check the ID isn't
already used (`ls src/content/*/ | grep <id>`).

| Kind | Folder |
|---|---|
| Article | `src/content/articles/<slug>-<id>/index.mdx` |
| Talk | `src/content/talks/<slug>-<id>/index.mdx` |
| Snap | `src/content/snaps/<slug>-<id>/index.md` |

## 2. Write the frontmatter

```yaml
---
title: Clean air & AI
publishedAt: '2026-10-01T07:00:00Z'
updatedAt: '2026-10-01T07:00:00Z'
tags: [hiking, ai]
---
```

- Leave `feedId` out. Only migrated entries have one.
- `draft: true` keeps it out of the build entirely. A future `publishedAt` schedules it: it
  appears with the first build after that time.
- Tags are lowercase with dashes. A new tag needs nothing else.
- A talk adds `event`, `heldAt`, and optionally `eventUrl` and `videoMirrorUrl`.
- A snap adds `image: snaps/<folder>/<file>` (a media key) and optionally `caption`, and
  has no body.

Set `updatedAt` again whenever you change a published entry; the sitemap reports it.

## 3. Write the body

Markdown, in MDX. Escape `{`, `}` and `<` in text with a backslash. Code blocks name their
language (```` ```ruby ````).

Images and videos are media: they go in `media/originals/`, not the entry's folder, and
through the components; never an `<img>` or a file in `public/`. The `new-media` skill is
how to add one:

```mdx
import Figure from "~/components/content/Figure.astro"

<Figure media="articles/<folder>/view.jpeg" caption="Zagreb from Sljeme" />
```

`<Gallery>` for images side by side (each `<Figure>` with `inGallery`), `<Video>` for a
clip with a poster image. The first `<Figure>` is the article's Open Graph image, so lead
with a good one.

## 4. Check it

```bash
npm run check
bin/preview
```

Open the entry, the index it's listed on, and `/feed`, and look at it at 390px wide as well.
A draft or a scheduled entry doesn't show up in any of them; set `draft: false` and a past
date temporarily if you need to see it.
