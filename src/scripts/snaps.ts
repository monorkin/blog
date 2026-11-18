import { justify, layout } from "~/scripts/justified-rows"

const MAX_ROTATION = 8
const TILT_REFERENCE_SIZE = 320
const MIN_PERSPECTIVE = 600
const PERSPECTIVE_PER_SIZE = 2
const TILT_TRANSITION = "transform 0.15s ease-out"
const RESET_TRANSITION = "transform 0.3s ease-out"
const COPIED_CLASS = "lightbox__actions--copied"
const COPIED_DURATION = 1500

const lightbox = document.getElementById("snap-lightbox") as HTMLDialogElement | null
const JUSTIFIED_GRID = ".photos-grid--justified"

document.querySelectorAll<HTMLElement>(JUSTIFIED_GRID).forEach(justify)

// A page that starts partway through a year adds its snaps to that year's rows
document.addEventListener("pagination:load", (event) => {
  const page = (event as CustomEvent<{ element: HTMLElement }>).detail.element
  const continued = page.querySelector(".snap-year--continued")
  const grids = [ ...document.querySelectorAll<HTMLElement>(JUSTIFIED_GRID) ]

  if (continued) {
    const yearGrid = grids[grids.indexOf(continued.querySelector(JUSTIFIED_GRID)!) - 1]
    yearGrid.append(...continued.querySelectorAll(`${JUSTIFIED_GRID} > *`))
    continued.remove()
    layout(yearGrid)
  }

  page.querySelectorAll<HTMLElement>(JUSTIFIED_GRID).forEach(justify)
})

document.addEventListener("click", (event) => {
  const target = event.target as HTMLElement
  const gridLink = target.closest<HTMLAnchorElement>("[data-snap-lightbox]")
  const navigationLink = target.closest<HTMLAnchorElement>("[data-snap-previous], [data-snap-next]")
  const copyButton = target.closest<HTMLElement>("[data-copy-link]")

  if (gridLink && lightbox) {
    event.preventDefault()
    openInLightbox(gridLink.href)
  } else if (navigationLink && lightbox?.open) {
    event.preventDefault()
    openInLightbox(navigationLink.href)
  } else if (copyButton) {
    copyLink(copyButton)
  }
})

document.addEventListener("keydown", (event) => {
  const scope = lightbox?.open ? lightbox : document

  if (event.key === "ArrowLeft") {
    scope.querySelector<HTMLAnchorElement>("[data-snap-previous]")?.click()
  } else if (event.key === "ArrowRight") {
    scope.querySelector<HTMLAnchorElement>("[data-snap-next]")?.click()
  }
})

document.addEventListener("mousemove", (event) => {
  const item = (event.target as HTMLElement).closest<HTMLElement>("[data-snap-tilt]")

  if (item) {
    tilt(item, event)
  }
})

document.addEventListener("mouseout", (event) => {
  const item = (event.target as HTMLElement).closest<HTMLElement>("[data-snap-tilt]")

  if (item && !item.contains(event.relatedTarget as Node)) {
    item.style.transform = ""
    item.style.transition = RESET_TRANSITION
  }
})

async function openInLightbox(url: string) {
  const frame = lightbox!.querySelector(".dialog__frame")!

  if (!lightbox!.open) {
    frame.replaceChildren(loadingIndicator())
    lightbox!.showModal()
    document.body.classList.add("overflow-hidden")
  }

  const response = await fetch(url)
  const page = new DOMParser().parseFromString(await response.text(), "text/html")
  frame.replaceChildren(...page.getElementById("snap_lightbox")!.childNodes)
  dropTransitionNames(frame)
}

// The snap's page names its picture like the thumbnail in the grid, so a navigation morphs
// one into the other; in the lightbox both are on one page, and a name must be unique
function dropTransitionNames(element: Element) {
  for (const named of element.querySelectorAll<HTMLElement>("[style*='view-transition-name']")) {
    named.style.viewTransitionName = "none"
  }
}

function loadingIndicator() {
  const element = document.createElement("div")
  element.className = "dialog__loading"
  element.textContent = "Loading..."
  return element
}

function copyLink(button: HTMLElement) {
  const actions = button.closest("[data-snap-actions]")!

  navigator.clipboard.writeText(button.dataset.copyLink!).then(() => {
    actions.classList.add(COPIED_CLASS)
    setTimeout(() => actions.classList.remove(COPIED_CLASS), COPIED_DURATION)
  })
}

function tilt(item: HTMLElement, { clientX, clientY }: MouseEvent) {
  const rect = item.getBoundingClientRect()
  const x = (clientX - rect.left) / rect.width
  const y = (clientY - rect.top) / rect.height
  const rotateY = (x - 0.5) * maxRotationAcross(rect.width) * 2
  const rotateX = (0.5 - y) * maxRotationAcross(rect.height) * 2
  const perspective = Math.max(MIN_PERSPECTIVE, PERSPECTIVE_PER_SIZE * Math.max(rect.width, rect.height))

  item.style.transform = `perspective(${perspective}px) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`
  item.style.transition = TILT_TRANSITION
}

// Larger tiles tilt less, so their edges move no further than a small tile's and stay out of
// their neighbours
function maxRotationAcross(size: number) {
  return MAX_ROTATION * Math.min(1, TILT_REFERENCE_SIZE / size)
}

export {}
