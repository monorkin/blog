import type { GetStaticPaths } from "astro"
import { publishedEntries, type Entry } from "~/lib/entries"
import { markdownResponse } from "~/lib/markdown"

export const getStaticPaths = (async () => {
  const articles = await publishedEntries("article")
  return articles.map(article => ({ params: { article: article.id }, props: { article } }))
}) satisfies GetStaticPaths

export function GET({ props }: { props: { article: Entry } }) {
  return markdownResponse(props.article)
}
