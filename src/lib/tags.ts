import knownTags from "~/data/tags.json"
import { publishedEntries, type Entry } from "~/lib/entries"

export interface Tag {
  name: string
  updatedAt: Date
  entries: Entry[]
}

// Tags come from the published entries, plus the ones the Rails app knew
// about, whose pages stay up even when nothing published uses them.
export async function allTags(): Promise<Tag[]> {
  const entries = await publishedEntries()
  const names = new Set([ ...knownTags.map(tag => tag.name), ...entries.flatMap(entry => entry.tags) ])

  return [ ...names ].sort().map(name => {
    const tagged = entries.filter(entry => entry.tags.includes(name))
    return { name, entries: tagged, updatedAt: lastUpdate(name, tagged) }
  })
}

export function relatedTags(tag: Tag, tags: Tag[], limit = 10) {
  const counts = new Map<string, number>()

  for (const entry of tag.entries) {
    for (const name of entry.tags) {
      if (name !== tag.name) {
        counts.set(name, (counts.get(name) ?? 0) + 1)
      }
    }
  }

  return [ ...counts.entries() ]
    .sort(([ nameA, countA ], [ nameB, countB ]) => countB - countA || nameA.localeCompare(nameB))
    .slice(0, limit)
    .map(([ name ]) => tags.find(candidate => candidate.name === name)!)
}

function lastUpdate(name: string, entries: Entry[]) {
  const known = knownTags.find(tag => tag.name === name)

  if (known) {
    return new Date(known.updatedAt)
  } else {
    return new Date(Math.max(...entries.map(entry => entry.publishedAt.getTime())))
  }
}
