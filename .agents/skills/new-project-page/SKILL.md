---
name: new-project-page
description: Adding a page about a project under /projects — an MDX page with the project layout that lists itself, or a freeform Astro page — and replacing the placeholder. Use when asked to add, write up or showcase a project.
---

# A new project page

Projects aren't a content collection. Each is a page in `src/pages/projects/`, and its file
name is its URL: `src/pages/projects/air-quality-box.mdx` is `/projects/air-quality-box`.

## The usual case: MDX

```mdx
---
layout: ~/layouts/ProjectLayout.astro
title: Air Quality Box
description: A small box that measures the air in a room and shows it on its screen.
---

import Figure from "~/components/content/Figure.astro"

<Figure media="projects/air-quality-box/on-a-desk.jpeg" caption="The Air Quality Box on a desk" />

Text as in any article.
```

`/projects` lists every `.md` and `.mdx` page in the folder by title, with its description,
so there is nothing to register. `ProjectLayout` gives it the SEO tags, the back link and
the article typography.

Photos and screenshots of a project are media, keyed under `projects/<page name>/`; the
`new-media` skill is how to add them. Only something that is part of the page's own design,
like an icon, goes in `src/assets/`.

## A freeform page

When a project needs its own design, write an `.astro` page with `Layout` from
`~/layouts/Layout.astro` and pass `SeoTags` through the `head` slot, as
`src/pages/projects/index.astro` does. It isn't listed on `/projects` by itself; add it to the
list in `index.astro`.

## The placeholder

`src/pages/projects/blog.mdx` exists so the index has something on it. Delete it once there
is a real project.

## Check it

```bash
npm run check
bin/preview
```

Open `/projects` and the page, at 390px wide as well. It's in `/sitemap-pages.xml` without
doing anything.
