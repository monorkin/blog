import type { GetStaticPaths } from "astro"
import { publishedEntries, type Entry } from "~/lib/entries"
import { socialImage, socialImagePath } from "~/lib/social-image"

// A preview card for every article and talk that doesn't name its own image with `ogImage`;
// a snap is shared with its photo
export const getStaticPaths = (async () => {
  const entries = await publishedEntries()

  return entries
    .filter(entry => entry.usesGeneratedSocialImage)
    .map(entry => ({ params: { path: socialImagePath(entry).replace(/^\/og\/|\.png$/g, "") }, props: { entry } }))
}) satisfies GetStaticPaths

export async function GET({ props }: { props: { entry: Entry } }) {
  return new Response(new Uint8Array(await socialImage(props.entry)), {
    headers: { "Content-Type": "image/png" }
  })
}
