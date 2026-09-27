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
}

const EXTENSIONS: Record<string, string> = { jpeg: "jpg", png: "png", webp: "webp" }
const MIME_TYPES: Record<string, string> = { jpeg: "image/jpeg", png: "image/png", webp: "image/webp" }
const media = manifest as Record<string, Media>

export function findMedia(key: string) {
  const entry = media[key]

  if (entry) {
    return entry
  } else {
    throw new Error(`No media "${key}" in src/data/media.json. Put it in media/originals and run bin/media variants.`)
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

// The variant in the original's format that's at least `width` wide, or the largest there is
export function variantAtLeast(key: string, width: number) {
  const entry = findMedia(key)

  if (isResizable(entry)) {
    const chosen = entry.widths!.find(candidate => candidate >= width) ?? entry.widths!.at(-1)!
    return variantUrl(key, `${chosen}w`, entry.formats!.at(-1)!)
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

function variantUrl(key: string, name: string, format: string) {
  return `${MEDIA_URL}/variants/${encodePath(key)}/${name}.${EXTENSIONS[format]}`
}

function encodePath(key: string) {
  return key.split("/").map(encodeURIComponent).join("/")
}
