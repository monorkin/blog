const LOADED_CLASS = "attachment__image--loaded"
const EXPANDED_CLASS = "attachment--expanded"
const PHONE = window.matchMedia("(width < 600px)")

function markLoaded(image: HTMLImageElement) {
  image.classList.add(LOADED_CLASS)
}

for (const image of document.querySelectorAll<HTMLImageElement>("img.attachment__image")) {
  if (image.complete) {
    markLoaded(image)
  } else {
    image.addEventListener("load", () => markLoaded(image), { once: true })
    image.addEventListener("error", () => markLoaded(image), { once: true })
  }
}

// Only phones cap tall images, so only there is there anything to expand
document.addEventListener("click", (event) => {
  const figure = (event.target as HTMLElement).closest(".attachment--expandable")

  if (figure && PHONE.matches) {
    figure.classList.toggle(EXPANDED_CLASS)
  }
})
