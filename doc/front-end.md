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
styles (vendored in `src/styles/vendor/`), then the app's files. The app's files sit in the
layers `reset, base, components, utilities`, so order rarely matters. Lexxy's styles aren't
in a layer, so they beat any layered rule for what they set, such as the margins of headings,
paragraphs and lists in entries; change those in `vendor/lexxy-overrides.css`, which is
unlayered too.

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
follows the system when it's `auto`. It exposes `window.colorScheme`, which the appearance
pickers use (`src/scripts/settings.ts`).

## Header, menu and appearance

The header isn't sticky; it scrolls away with the page. On a desktop it has the section
links, a search icon (its tooltip and the empty search mention the `/` shortcut) and a cog
that opens a small popover (`popover`, placed under the button by `settings.ts`). Under
600px the links and the cog give way to the search icon and a `Menu` button, which opens
`#menu`: a modal sheet from the top with the links and the appearance picker. The picker
(`src/components/AppearancePicker.astro`) is a radio group, Light, System and Dark, used in
the popover, the menu and on `/settings`, which is there for visitors without JavaScript.

Panels that drop in (the search, the menu, the popover) share the `.sheet` styles in
`dialog.css`: a fade and a short slide, dropped when reduced motion is on. They open in
the top layer, so nothing on the page moves when they do.

## Scripts

Small modules in `src/scripts/`, bundled by Astro. They listen on `document` and find their
elements through `data-*` attributes, so they also work on content added later.

| Script | Does |
|---|---|
| `dialogs.ts` | Opens `[data-dialog-open="<id>"]` dialogs, closes on `[data-dialog-close]` and outside clicks |
| `settings.ts` | The appearance radios, and placing the appearance popover |
| `search.ts` | The search panels, and opening search on `/`, Ctrl/Cmd+K or a `[data-search-open]` link |
| `attachments.ts` | Expands tall images on a phone |
| `placeholders.ts` | Marks images on a placeholder loaded, so they fade in over it (`doc/images.md`) |
| `gallery.ts` | Opens a gallery's images full size in a lightbox, with arrow keys |
| `pagination.ts` | Loads the next page when "Load more" comes near, and puts its content in place of the link |
| `link-previews.ts` | The link preview popups in articles: popovers in the top layer, placed below or above the link, so they never move the text around it |
| `snaps.ts` | The snap lightbox, its arrow keys, copying a link, the tilt on the grid |

## Snaps

`/snaps` is a grid of square thumbnails up to 1200px wide, wider than the reading column,
four across on a desktop and three on a phone. Clicking one opens the snap in a lightbox
without leaving the page; the snap's own page, `/snaps/:slug-:id`, is the same lightbox as a
dark band between the header and the footer, so its white controls stay visible.

## Search

[Pagefind](https://pagefind.app) indexes the built site after `astro build` (`npm run build`
runs both). It indexes articles, talks, snaps and tag pages: the element marked
`data-pagefind-body`, with `data-pagefind-meta` for the type, the title and the date (read
from a `<time>`'s `datetime`), and `data-pagefind-filter="tag"` for each tag.
`src/scripts/search.ts` loads `/pagefind/pagefind.js` on the first search and shows the
twelve best matches in Pagefind's order, each with its kind, month and an excerpt with the
matches marked. Arrow keys move through them, Enter opens one, Escape closes. A search
starting with `#` lists what has that tag.

The search is a modal `<dialog>`: a panel near the top on a desktop, the whole screen on a
phone. `/search?search[term]=…` is the same panel as a page, for visitors without
JavaScript.

The index only exists in a build, so search works in `bin/preview`; in `bin/dev` the panel
says so instead of searching.

## Layout shift

Every image and video has its size set before it loads, from the media manifest
(`doc/images.md`), and on a phone tall images are capped by CSS.
Keep it that way: a new component that shows an image sets `width` and `height`.
