import type { Entry } from "~/lib/entries"

// The names an article's title and date share between a list and its page, so a navigation
// moves them from one to the other (src/styles/components/view-transitions.css). Unique per
// entry, so they never meet twice on one page.
export function transitionStyles(entry: Entry) {
  return {
    title: `view-transition-name: title-${entry.id}`,
    meta: `view-transition-name: meta-${entry.id}`
  }
}
