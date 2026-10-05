---
name: new-entry
description: Adding a new article, talk or snap to the blog — generating it with bin/generate, the frontmatter, images and videos through the MDX components, and checking it before handing back. Use when asked to write, add or import a post, talk or photo.
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
and never changes once published, so get the title right. To change it later, use
`bin/rename <id> "New title"`: it keeps the ID, so the old URL redirects and the feed ID
stays (`doc/content.md`). Never make up an ID by hand.

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
tags: []
---
```

- There are no drafts or scheduling: every entry is built, and an entry stays unpublished
  only for as long as it isn't committed. Don't commit one unless Stanko asks.
- `publishedAt` is when it was generated. Set it to when it goes out, just before it's
  committed. A future date doesn't schedule anything; it only shows that date.
- Leave `feedId` out. Only migrated entries have one.
- Tags are lowercase with dashes. A new tag needs nothing else.
- A talk gets placeholder `event` and `heldAt` to replace, and `kind: meetup`; set it to
  `conference` for a conference. It optionally takes `eventUrl`; a recording goes in as
  `video: talk.mp4`, and `bin/media variants` makes its poster (the new-media skill), with
  the YouTube copy, if any, as `videoMirrorUrl`. Either marks the talk as having a video.
- A snap has `image: <file>` when you gave it a photo; run `bin/media variants` so the
  manifest knows it. It has no body, so give it a `caption` of a sentence or two
  saying what's in the photo; without one the page is too thin for search engines.
- Keep the order: title, the dates, tags, what the kind adds.

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

`<Gallery>` for images side by side (each `<Figure>` with `inGallery`), `<Video media="demo.mp4" />` for a
video, whose poster `bin/media variants` makes. When it's shared, an article or talk shows a
generated preview card; `ogImage: <file>` in the frontmatter shows that image instead
(`doc/content.md`).

## 4. Check it

```bash
bin/link-previews
bin/media variants
npm run check
bin/preview
```

`bin/link-previews` fetches the hover cards for any links the entry added; without it they
have none. It changes `src/data/link-previews.json` and adds `link-previews/` media, which
`bin/media variants` then puts in the manifest.

Open the entry, the index it's listed on, and `/feed`, and look at it at 390px wide as well.
