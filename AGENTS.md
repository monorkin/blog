# Blog

This file provides guidance to AI coding agents working with this repository.

## What is this project?

This is my personal blog, a static [Astro](https://astro.build) site hosted on Cloudflare Workers.

It used to be a Rails app. The content was exported from it once, and URLs, markup and CSS were kept the same.

## Development Commands

```bash
npm install
npm run dev        # Development server with live reload, media served from media/ at /media
npm run build      # astro build, then Pagefind indexes dist/client for search
npm run preview    # wrangler dev, serves the build like production does
npm run check      # Type-checks the project
```

Rebuild before `npm run preview`, and restart it after every build.

## Architecture Overview

### Content

Content lives in content collections, defined in `src/content.config.ts`. Each entry is a folder named after its URL, holding an `index.mdx` (or `index.md`) and its media.

- **Articles** (`src/content/articles/`) are served from the root as `/:slug-:id`.
- **Talks** (`src/content/talks/`) are served from `/talks/:slug-:id`. The body is the talk's abstract.
- **Snaps** (`src/content/snaps/`) are photos, served from `/snaps/:slug-:id`. They're frontmatter only.
- **Projects** are freeform `.astro`/`.mdx` pages in `src/pages/projects/`. The index lists every `.md`/`.mdx` page there.

Images in article bodies use the `<Figure>`, `<Gallery>` and `<Video>` components from `src/components/content/`, naming the media by its key, e.g. `<Figure media="articles/<folder>/photo.jpeg" />`.

`src/lib/entries.ts` wraps entries of all three collections in an `Entry` with the shared logic: paths, publishing, excerpts, reading time and cover images.

### Slugs

A slug has a free-form, URL-safe prefix and an alphanumeric suffix, e.g. `/my-first-article-abc123`. The suffix identifies the entry. The on-demand catch-all route (`src/pages/[...path].ts`) redirects URLs with an outdated prefix, like `/another-prefix-abc123` or `/abc123`, to the current one. This is a holdover from when the blog was hosted on Medium, which used this slug format.

### Publishing

Entries with `draft: true` aren't built. Entries whose `publishedAt` is in the future aren't built either, until a build runs after that time. A daily scheduled rebuild publishes them.

### Feed

The Atom feed at `/feed` is the only route rendered on demand. At build time `/feed/entries.json` is generated with every published entry; the Worker filters it by `?types=` and `?tag=` (both comma-separated). `/feed/style` is an XSL stylesheet that makes the feed look like a web page in a browser.

### Search

Search uses [Pagefind](https://pagefind.app), which indexes articles, talks and tag pages after `astro build`. `#tag` searches by tag.

### Media

Uploaded images and videos aren't in git. The originals live in R2 (bucket `stanko-io`, served at `https://media.stanko.io`) and locally in the gitignored `media/originals/`, named by key: the path under that directory. `media/variants/` holds their resized versions, and `src/data/media.json`, which is committed, describes each original's size and variants, so the build never needs the files. Components build URLs from `MEDIA_URL`, which `npm run dev` points at the local `media/`.

### Breakpoints

The responsive breakpoints follow a mobile-first approach:

| Name | Width    |
|------|----------|
| sm   | 640px    |
| md   | 768px    |
| lg   | 1024px   |
| xl   | 1280px   |
| 2xl  | 1536px   |

Use `@media (width >= <value>)` syntax in CSS.

The header and the about page switch from the phone to the desktop layout at 600px instead of `sm`, so that the unfolded iPhone Duo (626pt wide) and the iPad mini get the desktop layout.

### SEO

Each public-facing page must have all the search engine optimization (SEO) metadata properly filled out, including title, description, Open Graph tags, Twitter Card tags, canonical URL, and a sitemap entry.

Pages pass their tags to the layout's `head` slot. Entries use `EntrySeoTags`, which derives the title (truncated at word boundaries to fit browser limits), the description (the entry's excerpt, max 160 chars), the canonical URL and a 512x512 image from the entry's cover image, falling back to `src/assets/images/default_seo_image.jpg`. Other pages use `SeoTags` directly.

Each page must have a visible H1 tag with its title. The H1 can be styled not to look like a header, but it must be present in the HTML for SEO purposes.

The sitemap uses an index structure (`/sitemap.xml`) linking to sub-sitemaps per content type (pages, articles, talks, tags, snaps). When adding a new public content type, add a corresponding sub-sitemap.

All images must have alt text, and all links must have descriptive text naturally woven into the sentence (not "click here", but "RSS feed").

### JavaScript

There is no framework. Behavior lives in small modules in `src/scripts/` that Astro bundles, and in one inline script in the layout that applies the color scheme before the page paints.

## Coding style

@STYLE.md
