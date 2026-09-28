import type { Entry } from "~/lib/entries"

// The names an entry's parts share between a list and the entry's page, so a navigation
// moves them from one to the other (src/styles/components/view-transitions.css). Unique per
// entry, so they never meet twice on one page.
export function transitionStyles(entry: Entry) {
  const name = (part: string) => `view-transition-name: ${part}-${entry.id}`

  return {
    title: name("title"),
    meta: name("meta"),
    event: name("event"),
    date: name("date"),
    labels: name("labels"),
    // A snap's picture changes shape on the way, from a square thumbnail to the whole photo
    image: `${name("image")}; view-transition-class: snap-image`
  }
}
