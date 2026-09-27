const EXPANDED_CLASS = "attachment--expanded"
const PHONE = window.matchMedia("(width < 600px)")

// Only phones cap tall images, so only there is there anything to expand
document.addEventListener("click", (event) => {
  const figure = (event.target as HTMLElement).closest(".attachment--expandable")

  if (figure && PHONE.matches) {
    figure.classList.toggle(EXPANDED_CLASS)
  }
})
