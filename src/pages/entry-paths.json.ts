import { publishedEntries } from "~/lib/entries"

// Every published entry's kind and path, for the Worker to find an entry by the ID in a URL
// (src/pages/[...path].ts) without reading the content collections at request time
export async function GET() {
  const entries = await publishedEntries()
  const paths = entries.map(entry => ({ kind: entry.kind, path: entry.path }))

  return new Response(JSON.stringify(paths), { headers: { "Content-Type": "application/json" } })
}
