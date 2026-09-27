---
name: new-project-page
description: Adding a page about a project under /projects — generating an MDX page with bin/generate, drafts, or a freeform Astro page — and replacing the placeholder. Use when asked to add, write up or showcase a project.
---

# A new project page

Projects aren't a content collection. Each is a page in `src/pages/projects/`, and its file
name is its URL: `src/pages/projects/air-quality-box.mdx` is `/projects/air-quality-box`.

## The usual case: MDX

```bash
bin/generate project "Air Quality Box"
```

That writes `src/pages/projects/air-quality-box.mdx` (projects have no ID; the slug is the
URL) and makes its media folder, `media/originals/projects/air-quality-box/`. Fill it in:

```mdx
---
layout: ~/layouts/ProjectLayout.astro
title: "Air Quality Box"
description: A small box that measures the air in a room and shows it on its screen.
draft: true
---

import Figure from "~/components/content/Figure.astro"

<Figure media="on-a-desk.jpeg" caption="The Air Quality Box on a desk" />

Text as in any article.
```

`/projects` lists every `.md` and `.mdx` page in the folder by title, with its description,
so there is nothing to register. `ProjectLayout` gives it the SEO tags, the back link and
the article typography.

`draft: true` works differently from entries: every page in `src/pages` is built, so a draft
project is at its URL, but it isn't listed on `/projects` or in the sitemap and asks search
engines not to index it. Remove it when the page is ready.

Photos and screenshots of a project are media, in `media/originals/projects/<page name>/`,
and the page names them by file, like an entry does; the `new-media` skill is how to add
them. Unlike entries, a project page is an ordinary page, so it imports `Figure` (and
`Gallery` or `Video`) itself. Only something that is part of the page's own design, like an
icon, goes in `src/assets/`.

## A freeform page

When a project needs its own design, write an `.astro` page with `Layout` from
`~/layouts/Layout.astro` and pass `SeoTags` through the `head` slot, as
`src/pages/projects/index.astro` does. It isn't listed on `/projects` by itself; add it to
`listedProjects()` in `src/lib/projects.ts`.

## The placeholder

`src/pages/projects/blog.mdx` exists so the index has something on it. Delete it once there
is a real project.

## Check it

```bash
npm run check
bin/preview
```

Open `/projects` and the page, at 390px wide as well. Once it isn't a draft, it's in
`/sitemap-pages.xml` without doing anything.
