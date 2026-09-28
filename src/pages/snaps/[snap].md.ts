import type { GetStaticPaths } from "astro"
import { publishedEntries, type Entry } from "~/lib/entries"
import { markdownResponse } from "~/lib/markdown"

export const getStaticPaths = (async () => {
  const snaps = await publishedEntries("snap")
  return snaps.map(snap => ({ params: { snap: snap.id }, props: { snap } }))
}) satisfies GetStaticPaths

export function GET({ props }: { props: { snap: Entry } }) {
  return markdownResponse(props.snap)
}
