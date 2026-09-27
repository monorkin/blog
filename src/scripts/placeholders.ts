// Marks images that sit on a placeholder once they've loaded, so they fade in over it and it
// goes away (src/styles/components/placeholder.css)

const LOADED_CLASS = "placeholder__image--loaded"
const PLACEHELD_IMAGES = ".placeholder > img, img.placeholder"

// load and error don't bubble, but the document sees them on the way down, for images added
// later (the next page of a list, a snap opened in the lightbox) too
document.addEventListener("load", markIfPlaceheld, true)
document.addEventListener("error", markIfPlaceheld, true)

for (const image of document.querySelectorAll<HTMLImageElement>(PLACEHELD_IMAGES)) {
  if (image.complete) {
    image.classList.add(LOADED_CLASS)
  }
}

function markIfPlaceheld(event: Event) {
  const target = event.target as HTMLElement

  if (target instanceof HTMLImageElement && target.matches(PLACEHELD_IMAGES)) {
    target.classList.add(LOADED_CLASS)
  }
}
