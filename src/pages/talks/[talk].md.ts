import type { GetStaticPaths } from "astro"
import { publishedEntries, type Entry } from "~/lib/entries"
import { markdownResponse } from "~/lib/markdown"

export const getStaticPaths = (async () => {
  const talks = await publishedEntries("talk")
  return talks.map(talk => ({ params: { talk: talk.id }, props: { talk } }))
}) satisfies GetStaticPaths

export function GET({ props }: { props: { talk: Entry } }) {
  return markdownResponse(props.talk)
}
