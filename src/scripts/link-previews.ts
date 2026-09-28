// Shows a card for a link's destination when hovering over links in an article. The
// previews were saved by the Rails app, and each page embeds its own (LinkPreviews.astro).
//
// The card is a popover in the top layer, outside the article, so showing it never changes
// the layout of the text around the link.

// Long enough that moving the pointer across a paragraph doesn't flash cards open
const SHOW_DELAY = 150
const GAP = 10
// How close the arrow may get to the card's corners
const ARROW_INSET = 20

interface LinkPreview {
  host: string
  title?: string
  description?: string
  image?: { src: string, width?: number, height?: number, placeholder?: string }
}

const data = document.getElementById("link-previews")
const previews: Record<string, LinkPreview> = JSON.parse(data?.textContent || "{}")
const cards = new WeakMap<HTMLAnchorElement, HTMLElement>()
const pendingShows = new WeakMap<HTMLAnchorElement, number>()

for (const container of document.querySelectorAll("[data-link-previews]")) {
  container.addEventListener("mouseover", (event) => {
    const link = linkFor(event)

    if (link && !pendingShows.has(link)) {
      pendingShows.set(link, window.setTimeout(() => show(link), SHOW_DELAY))
    }
  })

  container.addEventListener("mouseout", (event) => {
    const link = linkFor(event)

    if (link && !link.contains((event as MouseEvent).relatedTarget as Node)) {
      hide(link)
    }
  })
}

function linkFor(event: Event) {
  const link = (event.target as HTMLElement).closest("a")

  if (link && previews[link.getAttribute("href")!]) {
    return link
  }
}

function show(link: HTMLAnchorElement) {
  if (!cards.has(link)) {
    cards.set(link, createCard(previews[link.getAttribute("href")!]))
  }

  const card = cards.get(link)!

  if (!card.matches(":popover-open")) {
    card.showPopover()
  }

  position(card, link)
}

function hide(link: HTMLAnchorElement) {
  const card = cards.get(link)

  window.clearTimeout(pendingShows.get(link))
  pendingShows.delete(link)

  if (card?.matches(":popover-open")) {
    card.hidePopover()
  }
}

function createCard(preview: LinkPreview) {
  const card = element("div", "link-preview")
  const body = element("div", "link-preview__body")

  if (preview.image) {
    card.append(image(preview.image))
  }

  body.append(text("div", "link-preview__host", preview.host))

  if (preview.title) {
    body.append(text("div", "link-preview__title", preview.title))
  }

  if (preview.description) {
    body.append(text("p", "link-preview__description", preview.description))
  }

  card.append(body, element("div", "link-preview__arrow"))
  card.popover = "manual"
  document.body.append(card)

  return card
}

function image({ src, width, height, placeholder }: NonNullable<LinkPreview["image"]>) {
  const node = element("img", "link-preview__image") as HTMLImageElement
  node.src = src
  node.alt = ""

  if (width && height) {
    node.width = width
    node.height = height
    node.dataset.width = String(width)
    node.dataset.height = String(height)
  }

  if (placeholder) {
    node.classList.add("placeholder")
    node.style.cssText = placeholder
  }

  return node
}

// Below the link's last line, or above its first when there's no room, so a link that wraps
// is never covered; centered on that line, and kept inside the viewport. When it fits on
// neither side, it drops its image and goes where there's more room.
function position(card: HTMLElement, link: HTMLAnchorElement) {
  const lines = [ ...link.getClientRects() ]
  const lastLine = lines[lines.length - 1]
  const roomBelow = window.innerHeight - lastLine.bottom - GAP * 2
  const roomAbove = lines[0].top - GAP * 2

  delete card.dataset.compact
  if (card.offsetHeight > roomBelow && card.offsetHeight > roomAbove) {
    card.dataset.compact = ""
  }

  let line, top
  if (card.offsetHeight <= roomBelow || roomBelow >= roomAbove) {
    card.dataset.placement = "bottom"
    line = lastLine
    top = lastLine.bottom + GAP
  } else {
    card.dataset.placement = "top"
    line = lines[0]
    top = lines[0].top - card.offsetHeight - GAP
  }

  const viewportWidth = document.documentElement.clientWidth
  const center = line.left + line.width / 2
  const left = Math.min(Math.max(center - card.offsetWidth / 2, GAP), viewportWidth - card.offsetWidth - GAP)

  const arrowLeft = Math.min(Math.max(center - left, ARROW_INSET), card.offsetWidth - ARROW_INSET)

  card.style.left = `${left + window.scrollX}px`
  card.style.top = `${top + window.scrollY}px`
  card.style.setProperty("--arrow-left", `${arrowLeft}px`)
  pointArrow(card, arrowLeft)
}

// An arrow on top of a card that starts with its image is cut from that image, so the
// picture runs up into the point
function pointArrow(card: HTMLElement, arrowLeft: number) {
  const image = card.querySelector<HTMLImageElement>(".link-preview__image")

  if (image?.dataset.width && card.dataset.placement === "bottom" && card.dataset.compact === undefined) {
    card.dataset.arrow = "image"
    cutArrowFrom(image, card, arrowLeft)
  } else {
    delete card.dataset.arrow
  }
}

// The image is drawn like object-fit: cover from the top, so the arrow draws the same image at
// the same size and offset, shifted by where the arrow sits
function cutArrowFrom(image: HTMLImageElement, card: HTMLElement, arrowLeft: number) {
  const arrow = card.querySelector<HTMLElement>(".link-preview__arrow")!
  const scale = Math.max(image.clientWidth / Number(image.dataset.width), image.clientHeight / Number(image.dataset.height))
  const drawnWidth = Number(image.dataset.width) * scale
  const drawnHeight = Number(image.dataset.height) * scale
  const imageLeft = (image.clientWidth - drawnWidth) / 2

  card.style.setProperty("--arrow-image", `url("${image.currentSrc || image.src}")`)
  card.style.setProperty("--arrow-image-size", `${drawnWidth}px ${drawnHeight}px`)
  card.style.setProperty("--arrow-image-position", `${imageLeft - (arrowLeft - arrow.offsetWidth / 2)}px 0`)
}

function text(tag: string, className: string, content: string) {
  const node = element(tag, className)
  node.textContent = content
  return node
}

function element(tag: string, ...classes: string[]) {
  const node = document.createElement(tag)
  node.classList.add(...classes)
  return node
}

export {}
