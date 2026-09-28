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

### Creating one

```bash
bin/generate article "Title"
bin/generate talk "Title"
bin/generate snap "Title" [path/to/photo.jpg]
bin/generate project "Title"
```

`bin/generate` makes the slug from the title the way Rails' `parameterize` did (accents and
apostrophes dropped, every other run of non-alphanumerics one dash), picks a fresh ID no
entry uses, and writes the file with `draft: true`, `publishedAt` and `updatedAt` set to now,
and `tags: []`. Talks get placeholder `event` and `heldAt`, and `kind: meetup`. It also makes the entry's media
folder, and for a snap copies the photo there and sets `image`. It prints the file and the
URL the entry will have. Don't make IDs by hand.

### Frontmatter

All three share these, always in this order: title, the dates and tags first, anything the
kind adds after them, `draft` and `feedId` last. Dates are bare YAML timestamps, tags an
inline list, and strings are quoted only when YAML needs it.

```yaml
title: Clean air & AI
publishedAt: 2025-06-12T14:00:00Z   # when it's shown as published, and the sort order
updatedAt: 2026-03-11T13:32:32Z     # the sitemap's lastmod
tags: [ai, go]                      # lowercase, dashes for spaces
ogImage: img_8969.jpeg              # optional; the image shown when it's shared (below)
draft: true                         # optional; drafts aren't built
feedId: Article/46                  # migrated entries only, see below
```

Talks add `event`, `kind`, `eventUrl`, `heldAt`, `video`, `poster` and `videoMirrorUrl`.
`kind` is `conference` or `meetup`, and is required; the talks list and the talk's page
label it. The rest are optional. `video` is a media key, named by file like an entry's
figures (`video: talk.mp4`): the recording we host, which the talk's page plays with a
native player. Its poster is the image beside it with the same name, `talk.jpg`, which
`bin/media variants` makes when it's missing; `poster` names a different one, which is
rarely needed (`doc/images.md`). `videoMirrorUrl` is a copy elsewhere, on YouTube:
with a `video` it's only the "View via mirror" link, without one its player is embedded. A
talk with either is marked as having a video. The body is the talk's abstract.

Snaps have no body. They add `caption`, then `image` or `video`. The media are named by
file, like `image: 1000054880.jpg` (see below). A video snap's poster, type and length come
from the video and the manifest; `poster`, `videoType` and `duration` override them, and
are rarely needed.

`feedId` is the Atom entry ID the Rails app gave the entry. Feed readers remember it, so it
must never change. New entries leave it out and get `<Kind>/<id>`, the ID at the end of the
folder name, so it survives a rename.

### Renaming

```bash
bin/rename article 8s17uw9GPHgD "A year at 37signals"
bin/rename 8s17uw9GPHgD "A year at 37signals"   # the kind is optional
```

It sets the new title, and renames the entry's folder to the new slug with the same ID, and
its media folders under `media/originals/` and `media/variants/` with it. It then rewrites
the media's keys in `src/data/media.json` and in any entry that uses them by full key. The
old URL keeps working, because the catch-all route redirects any slug with the right ID
(`doc/routes.md`), and the feed ID doesn't change. After renaming an entry that has media,
run `bin/media sync`: its files have new keys in R2.

### Publishing and scheduling

An entry is built when it isn't a `draft` and its `publishedAt` is in the past at build time.
So a post is scheduled by giving it a future `publishedAt`: it appears with the first build
after that moment. A scheduled rebuild once a day publishes them (`doc/deployment.md`).

Drafts are left out completely, including from the feed, the sitemaps and the tag pages.

### Excerpts and reading time

Nothing is written by hand. The excerpt (list pages, feed summary, 300 characters) and the
description (SEO, 160 characters) come from the entry's text, converted the way Action Text
converted it, so they matched the Rails app's at the migration. Reading time assumes 225
words a minute. All of this is in `src/lib/entries.ts` and `src/lib/plain-text.ts`.

### The image shown when it's shared

The Open Graph and Twitter image is, in order:

1. The media `ogImage` names, as its 512px square with a small card, the way the Rails app
   shared it. Migrated articles set it to the image Rails used, their first figure.
2. For a snap, its photo, the same way.
3. Otherwise a preview card made at build time, 1200×630 with a large card, in the site's
   dark colors: my portrait in black and white beside the title, the excerpt under them,
   and the date, or for a talk its event and date, across the top. It's at
   `/og/<the entry's path>.png`. `src/lib/social-image.ts` draws it with satori, in Inter
   from `@fontsource/inter`, and sharp makes it a PNG.

## MDX components

Articles and talks are MDX. Images and videos use `<Figure>`, `<Gallery>` and `<Video>`
from `src/components/content/`, which every entry gets without importing them
(`src/lib/rendering.ts` hands them to the content). An entry names its own media by file
name, which is looked up in its media folder, `media/originals/<collection>/<folder>/`
(`new-media` skill):

```mdx
<Figure media="breadboard.jpeg" caption="The first prototype" />

<Gallery>
  <Figure media="before.jpeg" caption="Before" inGallery />
  <Figure media="after.jpeg" caption="After" inGallery />
</Gallery>

<Video media="demo.mp4" caption="The demo" />
```

A key with a slash is a full key, for using another entry's media:
`<Figure media="snaps/soca-valley-C4wEfGoWTXNS/1000054880.jpg" />`.

`caption` also becomes the alt text; pass `alt` when it should differ, or instead of a
caption. `<Figure src="https://…" width={480} height={270} />` shows an image from another
site; no entry does that any more. A GIF becomes a short MP4 shown with `<Video … clip />`,
which plays like a GIF, without controls. `doc/images.md` has what each component renders.

The source reads like any Markdown: prose wrapped at 80 columns (list items and quotes
indented under their marker), blank lines between blocks, `**bold**`, `*italic*`,
`` `code` `` for anything that's code, `-` for lists, `##` or `###` for headings (never a
bold line standing in for one), and Markdown tables.
Links, code spans and component tags are never broken, so a long one overflows; a component
tag that doesn't fit on one line gets one attribute per line. Code blocks and tables aren't
wrapped. No raw HTML where Markdown has a way to say it.

Code blocks are fenced with a language (```` ```ruby ````); `text` for plain output, which
renders unhighlighted, as the Rails app did.

Text in MDX needs `{`, `}` and a `<` that could start a tag escaped with a backslash.

## Tags

A tag page exists for every tag an entry uses, plus the ones in `src/data/tags.json`: the
tags the Rails app had, with their dates for the sitemap. Two of them, `opinion` and
`ruby-docker`, are on no entry any more and still have a page, because the Rails app served
one. A new tag needs nothing but using it.

## Projects

The projects section is switched off for now (`doc/routes.md`), with its pages in
`src/pages/_projects/`; what follows is how it works when it's on.

Projects aren't a collection. Each is a page in `src/pages/projects/`, named after its slug
with no ID; `bin/generate project "Title"` writes one. An `.mdx` file with
`layout: ~/layouts/ProjectLayout.astro`, a `title` and a `description` shows up on
`/projects` by itself; an `.astro` page can be anything, but isn't listed unless it is
added to `src/lib/projects.ts`. `blog.mdx` is a placeholder.

A project with `draft: true` is still built, because every page in `src/pages` is, but it
isn't listed on `/projects` or in the sitemap, and it's marked `noindex`.

## The export from Rails

The content was exported once from the Rails app's production database, by
`~/Work/monorkin/blog-export/export.rb` (outside this repository), run with the Rails app's
`bin/rails runner` against a copy of the database. It wrote the collections and the tag and
link preview data, copied every attachment into `media/originals/`, and converted Action
Text's HTML to MDX. Its notes,
checks and lists (`MIGRATION_NOTES.md`, `urls.txt`, `manual-cleanup.txt`) are in that
directory. Running it again replaces every exported entry, so don't, once entries have been
edited here.
