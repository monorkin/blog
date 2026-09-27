# Content

Three content collections, defined in `src/content.config.ts`, and project pages beside them.

## Entries

Every entry is a folder under `src/content/<collection>/`, and the folder's name is its URL:

| Collection | Folder | File | URL |
|---|---|---|---|
| articles | `src/content/articles/<slug>-<id>/` | `index.mdx` | `/<slug>-<id>` |
| talks | `src/content/talks/<slug>-<id>/` | `index.mdx` | `/talks/<slug>-<id>` |
| snaps | `src/content/snaps/<slug>-<id>/` | `index.md` | `/snaps/<slug>-<id>` |

The folder holds only the text. The images and videos an entry uses are media, outside git,
in `media/originals/<collection>/<folder name>/` (`doc/images.md`).

The `<id>` is 12 random letters and digits, like `AHcddmIf21lt`. It identifies the entry:
`/anything-AHcddmIf21lt` redirects to the entry's current URL (`doc/routes.md`), so the
slug in front of it can say anything. A few old entries have Medium's hex IDs instead.

### Frontmatter

All three share these:

```yaml
title: Clean air & AI
publishedAt: '2025-06-12T14:00:00Z'   # when it's shown as published, and the sort order
updatedAt: '2026-03-11T13:32:32Z'     # the sitemap's lastmod
draft: true                           # optional; drafts aren't built
tags: [ai, go]                        # lowercase, dashes for spaces
feedId: Article/46                    # migrated entries only, see below
```

Talks add `event`, `heldAt`, and optionally `eventUrl` and `videoMirrorUrl` (a YouTube URL
is embedded, anything else becomes a `<video>`). The body is the talk's abstract.

Snaps have no body. They add `image`, a media key, or `video` and `poster` keys with
`videoType` and `duration`, plus an optional `caption`.

`feedId` is the Atom entry ID the Rails app gave the entry. Feed readers remember it, so it
must never change. New entries leave it out and get `<Kind>/<folder name>`.

### Publishing and scheduling

An entry is built when it isn't a `draft` and its `publishedAt` is in the past at build time.
So a post is scheduled by giving it a future `publishedAt`: it appears with the first build
after that moment. A scheduled rebuild once a day publishes them (`doc/deployment.md`).

Drafts are left out completely, including from the feed, the sitemaps and the tag pages.

### Excerpts and reading time

Nothing is written by hand. The excerpt (list pages, feed summary, 300 characters) and the
description (SEO, 160 characters) come from the entry's text, converted the way Action Text
converted it, so they matched the Rails app's at the migration. The cover image, used for
Open Graph, is the article's first `<Figure>`, or a snap's image. Reading time assumes 225
words a minute. All of this is in `src/lib/entries.ts` and `src/lib/plain-text.ts`.

## MDX components

Articles and talks are MDX. Images and videos use the components in
`src/components/content/`, naming the media by its key (`new-media` skill):

```mdx
import Figure from "~/components/content/Figure.astro"
import Gallery from "~/components/content/Gallery.astro"
import Video from "~/components/content/Video.astro"

<Figure media="articles/air-quality-box-Xifl2b1XyubA/breadboard.jpeg" caption="The first prototype" />

<Gallery>
  <Figure media="articles/air-quality-box-Xifl2b1XyubA/before.jpeg" caption="Before" inGallery />
  <Figure media="articles/air-quality-box-Xifl2b1XyubA/after.jpeg" caption="After" inGallery />
</Gallery>

<Video media="articles/air-quality-box-Xifl2b1XyubA/demo.mp4" poster="articles/air-quality-box-Xifl2b1XyubA/demo.jpg" type="video/mp4" caption="The demo" />
```

`caption` also becomes the alt text; pass `alt` when it should differ. `doc/images.md` has
what each component renders.

Code blocks are fenced with a language (```` ```ruby ````). A fence without one renders as a
plain, unhighlighted block, as the Rails app did.

Text in MDX needs `{`, `}` and `<` escaped with a backslash, as the migrated entries do.

## Tags

A tag page exists for every tag an entry uses, plus the ones in `src/data/tags.json`: the
tags the Rails app had, with their dates for the sitemap. Two of them, `opinion` and
`ruby-docker`, are on no entry any more and still have a page, because the Rails app served
one. A new tag needs nothing but using it.

## Projects

Projects aren't a collection. Each is a page in `src/pages/projects/`: an `.mdx` file with
`layout: ~/layouts/ProjectLayout.astro`, a `title` and a `description` shows up on
`/projects` by itself; an `.astro` page can be anything, but isn't listed unless it is
added to `src/pages/projects/index.astro`. `blog.mdx` is a placeholder.

## The export from Rails

The content was exported once from the Rails app's production database, by
`~/Work/monorkin/blog-export/export.rb` (outside this repository), run with the Rails app's
`bin/rails runner` against a copy of the database. It wrote the collections and the tag and
link preview data, copied every attachment into `media/originals/`, and converted Action
Text's HTML to MDX. Its notes,
checks and lists (`MIGRATION_NOTES.md`, `urls.txt`, `manual-cleanup.txt`) are in that
directory. Running it again replaces every exported entry, so don't, once entries have been
edited here.
