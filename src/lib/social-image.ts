import { readdirSync, readFileSync } from "node:fs"
import type { CollectionEntry } from "astro:content"
import satori from "satori"
import sharp from "sharp"
import type { Entry } from "~/lib/entries"
import { formatDate } from "~/lib/site"

// The picture a link to an entry shows when it's shared, unless its `ogImage` names one: a
// card with my portrait beside the title, and the excerpt, in the site's dark colors. Satori
// lays it out and turns the text into shapes, and sharp makes that a PNG.

export const SOCIAL_IMAGE_WIDTH = 1200
export const SOCIAL_IMAGE_HEIGHT = 630

const EXCERPT_LENGTH = 220
const LONG_TITLE_LENGTH = 50
const PORTRAIT_SIZE = 136
const COLORS = { canvas: "#000000", ink: "#e4e4e7", subtle: "#a1a1aa", muted: "#71717a", accent: "#efb100", border: "#27272a" }

const FONT_WEIGHTS = [ 400, 700, 800 ] as const
// Inter has no Japanese, so Satori falls back to Noto Sans JP. Fontsource splits it into
// numbered subsets, and each needs its own name, or Satori keeps only one per weight
const JAPANESE_SUBSETS = readdirSync("node_modules/@fontsource/noto-sans-jp/files")
  .map(file => file.match(/^noto-sans-jp-(\d+)-400-normal\.woff$/)?.[1])
  .filter(subset => subset !== undefined)

const fonts = FONT_WEIGHTS.flatMap(weight => [
  font("Inter", weight, `node_modules/@fontsource/inter/files/inter-latin-${weight}-normal.woff`),
  ...JAPANESE_SUBSETS.map(subset =>
    font(`Noto Sans JP ${subset}`, weight, `node_modules/@fontsource/noto-sans-jp/files/noto-sans-jp-${subset}-${weight}-normal.woff`))
])
// Black and white, as the site shows it in dark mode
const portrait = sharp(readFileSync("src/assets/images/portrait/small.jpg")).grayscale().jpeg().toBuffer()
  .then(image => `data:image/jpeg;base64,${image.toString("base64")}`)

export function socialImagePath(entry: Entry) {
  return `/og${entry.path}.png`
}

export async function socialImage(entry: Entry) {
  const excerpt = (await entry.excerpt(EXCERPT_LENGTH)) ?? ""
  const card = element("div", {
    display: "flex", flexDirection: "column", width: "100%", height: "100%",
    padding: "56px 72px", backgroundColor: COLORS.canvas, borderBottom: `14px solid ${COLORS.accent}`
  }, [
    header(entry),
    element("div", { display: "flex", flexDirection: "column", flexGrow: 1, justifyContent: "center", gap: 32 }, [
      element("div", { display: "flex", alignItems: "center", gap: 40 }, [
        element("img", { width: PORTRAIT_SIZE, height: PORTRAIT_SIZE, borderRadius: PORTRAIT_SIZE / 2, flexShrink: 0 }, [], { src: await portrait, width: PORTRAIT_SIZE, height: PORTRAIT_SIZE }),
        title(entry.title)
      ]),
      element("div", { display: "block", fontSize: 30, lineHeight: 1.45, color: COLORS.subtle, lineClamp: 3 }, excerpt.replace(/\s+/g, " "))
    ])
  ])
  const svg = await satori(card as never, { width: SOCIAL_IMAGE_WIDTH, height: SOCIAL_IMAGE_HEIGHT, fonts })

  return sharp(Buffer.from(svg)).png().toBuffer()
}

// The site across the top, and when it was published, or for a talk where it was given
function header(entry: Entry) {
  return element("div", { display: "flex", alignItems: "center", justifyContent: "space-between", paddingBottom: 24, borderBottom: `2px solid ${COLORS.border}` }, [
    element("div", { fontSize: 28, color: COLORS.accent, fontWeight: 700 }, "stanko.io"),
    element("div", { fontSize: 24, color: COLORS.muted, textTransform: "uppercase", letterSpacing: 1 }, context(entry))
  ])
}

function context(entry: Entry) {
  if (entry.kind === "talk") {
    const talk = entry.source.data as CollectionEntry<"talks">["data"]
    return `${talk.event} · ${formatDate(talk.heldAt)}`
  } else {
    return formatDate(entry.publishedAt)
  }
}

// Long titles get a smaller size, so they still fit in three lines
function title(text: string) {
  let fontSize = 64
  if (text.length > LONG_TITLE_LENGTH) {
    fontSize = 50
  }

  return element("div", { display: "block", fontSize, fontWeight: 800, lineHeight: 1.1, color: COLORS.ink, lineClamp: 3 }, text)
}

function font(name: string, weight: typeof FONT_WEIGHTS[number], path: string) {
  return { name, weight, style: "normal" as const, data: readFileSync(path) }
}

// Satori takes the objects JSX would make
function element(type: string, style: Record<string, unknown>, children: unknown, attributes: Record<string, unknown> = {}) {
  return { type, props: { ...attributes, style, children } }
}
