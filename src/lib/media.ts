import { MEDIA_URL } from "astro:env/server"
import manifest from "~/data/media.json"

// Uploaded media: originals and their variants live in R2 (media/ locally), described by
// src/data/media.json, which `bin/media variants` writes. A key is a path under
// media/originals, e.g. "articles/clean-air-ai-AHcddmIf21lt/img_8969.jpeg".

export interface Media {
  type: string
  bytes: number
  width?: number
  height?: number
  formats?: string[]
  widths?: number[]
  squares?: number[]
  placeholder?: string
  color?: string
  // A video's, in whole seconds
  duration?: number
}

// The tiny image's longest side, as bin/media makes it, and how far it's blurred, in its pixels
const PLACEHOLDER_SIZE = 16
const PLACEHOLDER_BLUR = 1

const EXTENSIONS: Record<string, string> = { jpeg: "jpg", png: "png", webp: "webp" }
const POSTER_EXTENSIONS = [ "jpg", "jpeg", "png", "webp" ]
const MIME_TYPES: Record<string, string> = { jpeg: "image/jpeg", png: "image/png", webp: "image/webp" }
const media = manifest as Record<string, Media>

// An entry names its own media by file name alone ("img_8969.jpeg"), resolved against its
// folder ("articles/clean-air-ai-AHcddmIf21lt"); a key with a slash is already complete
export function resolveMediaKey(key: string, folder?: string) {
  if (key.includes("/")) {
    return key
  } else if (folder) {
    return `${folder}/${key}`
  } else {
    throw new Error(`Can't tell whose media "${key}" is. Use its full key, e.g. articles/<folder>/${key}.`)
  }
}

// Where an entry's own media lives: rendered entries say so through Astro.locals, and a
// project page's is named after its URL
export function mediaFolderFor(astro: { locals: App.Locals, url: URL }) {
  return astro.locals.mediaFolder ?? astro.url.pathname.replace(/^\/|\.html$/g, "")
}

export function findMedia(key: string) {
  const entry = media[key]

  if (entry) {
    return entry
  } else {
    throw new Error(`No media "${key}" in src/data/media.json. Put it in media/originals and run bin/media variants.`)
  }
}

// A video's poster is the image beside it with the same name, "demo.jpg" for "demo.mp4",
// which `bin/media variants` makes from a frame of the video when there isn't one
export function posterFor(videoKey: string) {
  const base = videoKey.replace(/\.[^./]+$/, "")
  const key = POSTER_EXTENSIONS.map(extension => `${base}.${extension}`).find(candidate => media[candidate])

  if (key) {
    return key
  } else {
    throw new Error(`No poster for "${videoKey}" in src/data/media.json. Run bin/media variants to make one.`)
  }
}

export function originalUrl(key: string) {
  findMedia(key)
  return `${MEDIA_URL}/originals/${encodePath(key)}`
}

export function isResizable(entry: Media) {
  return Boolean(entry.formats?.length)
}

// Every format's variants as srcset candidates, the original's format last
export function sources(key: string) {
  const entry = findMedia(key)

  return (entry.formats ?? []).map(format => ({
    format,
    type: MIME_TYPES[format],
    srcset: entry.widths!.map(width => `${variantUrl(key, `${width}w`, format)} ${width}w`).join(", ")
  }))
}

// The WebP variant that's at least `width` wide, or the largest there is. Every browser shows
// WebP, and crawlers judge a page by its images' `src`, where a PNG or JPEG can be megabytes.
export function variantAtLeast(key: string, width: number) {
  const entry = findMedia(key)

  if (isResizable(entry)) {
    const chosen = entry.widths!.find(candidate => candidate >= width) ?? entry.widths!.at(-1)!
    return variantUrl(key, `${chosen}w`, "webp")
  } else {
    return originalUrl(key)
  }
}

export function squareUrl(key: string, size: number, format?: string) {
  const entry = findMedia(key)

  if (entry.squares?.includes(size)) {
    return variantUrl(key, `${size}sq`, format ?? entry.formats!.at(-1)!)
  }
}

// Custom properties for the `placeholder` class (src/styles/components/placeholder.css): the
// image's tiny version blurred by an SVG filter, over its average color. The filter makes the
// blurred edges opaque, so they don't fade into the background.
export function placeholderStyle(key: string) {
  const entry = findMedia(key)

  if (entry.placeholder) {
    const scale = PLACEHOLDER_SIZE / Math.max(entry.width!, entry.height!)
    const width = Math.max(1, Math.round(entry.width! * scale))
    const height = Math.max(1, Math.round(entry.height! * scale))
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" preserveAspectRatio="none">` +
      `<filter id="b" color-interpolation-filters="sRGB"><feGaussianBlur stdDeviation="${PLACEHOLDER_BLUR}"/>` +
      `<feComponentTransfer><feFuncA type="discrete" tableValues="1 1"/></feComponentTransfer></filter>` +
      `<image width="100%" height="100%" preserveAspectRatio="none" filter="url(#b)" href="${entry.placeholder}"/></svg>`

    return `--placeholder: url("data:image/svg+xml,${encodeURIComponent(svg)}"); --placeholder-color: ${entry.color};`
  }
}

function variantUrl(key: string, name: string, format: string) {
  return `${MEDIA_URL}/variants/${encodePath(key)}/${name}.${EXTENSIONS[format]}`
}

function encodePath(key: string) {
  return key.split("/").map(encodeURIComponent).join("/")
}
