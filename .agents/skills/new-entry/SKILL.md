---
name: new-entry
description: Adding a new article, talk or snap to the blog — generating it with bin/generate, the frontmatter, images and videos through the MDX components, drafts and scheduling, and checking it before handing back. Use when asked to write, add, import or schedule a post, talk or photo.
---

# A new entry

`doc/content.md` is the reference for everything below; read it if a step is unclear.

## 1. Generate it

```bash
bin/generate article "Clean air & AI"
bin/generate talk "Deconstructing Action Cable"
bin/generate snap "Soca Valley" ~/Pictures/soca.jpg   # the photo is optional
```

It makes the folder, named `<slug>-<id>`: the slug from the title ("Clean air & AI" is
`clean-air-ai`) and a fresh 12-character ID nothing else uses. The folder's name is the URL
and never changes once published, so get the title right, or delete the folder and generate
again. Never make up an ID by hand.

It also makes the entry's media folder, `media/originals/<collection>/<folder>/`, copies a
snap's photo into it, and prints the file it wrote and the URL it will have.

| Kind | File |
|---|---|
| Article | `src/content/articles/<slug>-<id>/index.mdx` |
| Talk | `src/content/talks/<slug>-<id>/index.mdx` |
| Snap | `src/content/snaps/<slug>-<id>/index.md` |

## 2. Fill in the frontmatter

What it writes:

```yaml
---
title: "Clean air & AI"
publishedAt: '2026-10-01T07:00:00Z'
updatedAt: '2026-10-01T07:00:00Z'
draft: true
tags: []
---
```

- `draft: true` keeps it out of the build entirely. Remove it when it's ready.
- `publishedAt` is when it was generated. Set it to when it goes out: a future one schedules
  it, and it appears with the first build after that time.
- Leave `feedId` out. Only migrated entries have one.
- Tags are lowercase with dashes. A new tag needs nothing else.
- A talk gets placeholder `event` and `heldAt` to replace, and optionally takes `eventUrl`
  and `videoMirrorUrl`.
- A snap has `image: <file>` when you gave it a photo; run `bin/media variants` so the
  manifest knows it. It takes an optional `caption`, and has no body.
- Keep the order: title, the dates, tags, what the kind adds, `draft` last.

Set `updatedAt` again whenever you change a published entry; the sitemap reports it.

## 3. Write the body

Markdown, in MDX, like the other entries: prose wrapped at 80 columns, `**bold**`,
`*italic*`, `` `code` `` for code (never bold), `-` lists, `##` and `###` headings (not bold
lines), Markdown tables,
and no HTML where Markdown will do. Links, code spans and component tags aren't broken. Escape `{`, `}`
and a `<` that could start a tag with a backslash. Code blocks name their language
(```` ```ruby ````, `text` for plain output).

Images and videos are media: they go in the entry's media folder that `bin/generate` made,
`media/originals/<collection>/<folder>/`, and through the components, which need no import;
never an `<img>` or a file in `public/`. Name them by file; the `new-media` skill has the rest:

```mdx
<Figure media="view.jpeg" caption="Zagreb from Sljeme" />
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
