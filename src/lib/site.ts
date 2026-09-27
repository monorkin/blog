export const SITE_URL = "https://stanko.io"
export const SITE_NAME = "Stanko K.R."
export const AUTHOR_NAME = "Stanko Krtalic Rusendic"
export const AUTHOR_EMAIL = "hey@stanko.io"

export const PAGE_SIZE = 12

// The projects section is switched off by its folder's name: Astro doesn't route
// src/pages/_projects. Rename it to src/pages/projects and the pages, the header link and
// the sitemap entries come back.
export const PROJECTS_ENABLED = Object.keys(import.meta.glob("/src/pages/projects/index.astro")).length > 0

const TITLE_SEPARATOR = " - "
const RECOMMENDED_TITLE_MAX_LENGTH = 60
const TITLE_MAX_LENGTH = RECOMMENDED_TITLE_MAX_LENGTH - SITE_NAME.length - TITLE_SEPARATOR.length

export function titleize(name: string) {
  return [ truncate(name, TITLE_MAX_LENGTH), SITE_NAME ].join(TITLE_SEPARATOR)
}

// Mirrors ActiveSupport's String#truncate with `separator: " "`
export function truncate(text: string, length: number, omission = "...") {
  if (text.length <= length) {
    return text
  } else {
    const roomForOmission = length - omission.length
    let stop = text.lastIndexOf(" ", roomForOmission)

    if (stop === -1) {
      stop = roomForOmission
    }

    return text.slice(0, stop) + omission
  }
}

const MONTHS = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]

// Matches the Rails app's "%B %d, %Y" date format, in UTC
export function formatDate(date: Date) {
  const day = String(date.getUTCDate()).padStart(2, "0")

  return `${MONTHS[date.getUTCMonth()]} ${day}, ${date.getUTCFullYear()}`
}

// ISO 8601 without milliseconds, like Ruby's Time#iso8601
export function isoTimestamp(date: Date) {
  return date.toISOString().replace(/\.\d{3}Z$/, "Z")
}

export function absoluteUrl(path: string) {
  return new URL(path, SITE_URL).toString()
}
