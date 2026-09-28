// How bin/generate and bin/rename turn a title into an entry's slug and frontmatter

// Rails' parameterize, which made every slug so far: accents dropped, apostrophes too, and
// every run of anything else that isn't a letter or digit turned into one dash
export function slugFor(title) {
  return title
    .normalize("NFKD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/['’]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
}

// Quoted only when YAML would read it as something other than a string
export function yamlString(text) {
  if (/^[\p{L}\p{N}][^:#"'\\\n]*$/u.test(text) && !/^(true|false|null|yes|no|on|off|[\d.]+)$/i.test(text)) {
    return text
  } else {
    return JSON.stringify(text)
  }
}
