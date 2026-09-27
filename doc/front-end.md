# Front end

Astro components render all the HTML; there is no framework in the browser. The markup and
the CSS are the Rails app's, class for class, so the site looks the same.

## Layout

`src/layouts/Layout.astro` is every page: the head (a page passes its title and SEO tags
through the `head` slot), the analytics scripts, favicons and manifest, the header, the
footer, and the search and settings dialogs. `src/components/Header.astro` has the desktop
nav and, below 600px, the menu button and its dialog.

Project pages use `src/layouts/ProjectLayout.astro` on top of it.

## CSS

`src/styles/app.css` imports everything in the order the Rails app loaded it: Lexxy's content
styles (vendored in `src/styles/vendor/`), then the app's files. Everything sits in the
layers `reset, base, components, utilities`, so order rarely matters.

The breakpoints are mobile-first; write them as `@media (width >= <value>)`:

| Name | Width |
|------|-------|
| sm   | 640px |
| md   | 768px |
| lg   | 1024px |
| xl   | 1280px |
| 2xl  | 1536px |

The header and the about page switch from the phone to the desktop layout at 600px instead
of `sm`, so that the unfolded iPhone Duo (626pt wide) and the iPad mini get the desktop
layout.

Code blocks are highlighted by Shiki with its `css-variables` theme. `src/lib/code-blocks.js`
shapes the output like Rouge's, a `<pre class="highlight" data-language="…">`, and
`src/styles/components/highlight.css` maps the token variables onto the same Tokyo Night
palette in light and dark.

## Color scheme

The `color_scheme` cookie holds `auto`, `light` or `dark`, as it did in Rails, so a visitor's
choice carried over. An inline script at the top of `<head>` reads it and puts
`color-scheme--light` or `color-scheme--dark` on `<html>` before anything is drawn, and
follows the system when it's `auto`. It exposes `window.colorScheme`, which the settings
panel uses (`src/scripts/settings.ts`).

## Scripts

Small modules in `src/scripts/`, bundled by Astro. They listen on `document` and find their
elements through `data-*` attributes, so they also work on content added later.

| Script | Does |
|---|---|
| `dialogs.ts` | Opens `[data-dialog-open="<id>"]` dialogs, closes on `[data-dialog-close]` and outside clicks, Ctrl/Cmd+K for search |
| `settings.ts` | The color scheme radios |
| `search.ts` | The search panels |
| `attachments.ts` | Marks images loaded (ends the placeholder pulse), expands tall images on a phone |
| `gallery.ts` | Opens a gallery's images full size in a lightbox, with arrow keys |
| `pagination.ts` | Loads the next page when "Load more" comes near, and puts its content in place of the link |
| `link-previews.ts` | The link preview popups in articles |
| `snaps.ts` | The snap lightbox, its arrow keys, copying a link, the tilt on the grid |

## Snaps

`/snaps` is a grid of square thumbnails up to 1200px wide, wider than the reading column,
four across on a desktop and three on a phone. Clicking one opens the snap in a lightbox
without leaving the page; the snap's own page, `/snaps/:slug-:id`, is the same lightbox as a
dark band between the header and the footer, so its white controls stay visible.

## Search

[Pagefind](https://pagefind.app) indexes the built site after `astro build` (`npm run build`
runs both). It indexes articles, talks and tag pages: the element marked
`data-pagefind-body`, with `data-pagefind-meta` for the type and title and
`data-pagefind-filter="tag"` for each tag. `src/scripts/search.ts` loads
`/pagefind/pagefind.js` on the first search and shows up to five results each of articles,
talks and tags, like the old search. A search starting with `#` lists what has that tag.

The index only exists in a build, so search works in `bin/preview` and not in `bin/dev`.

## Layout shift

Every image and video has its size set before it loads, from the media manifest
(`doc/images.md`), and on a phone tall images are capped by CSS.
Keep it that way: a new component that shows an image sets `width` and `height`.
