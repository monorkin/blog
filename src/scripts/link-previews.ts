// Shows a preview of a link's destination when hovering over links in an
// article. The previews are fetched at build time and embedded in the page.
//
// A popup lives in the top layer, outside the article, so showing it never
// changes the layout of the text around the link.

const VIEWPORT_MARGIN = 8
const ARROW_INSET = 16

interface LinkPreview {
  title?: string
  description?: string
  image?: { src: string, width?: number, height?: number, placeholder?: string }
}

const data = document.getElementById("link-previews")
const previews: Record<string, LinkPreview> = JSON.parse(data?.textContent || "{}")
const popups = new WeakMap<HTMLAnchorElement, HTMLElement>()

for (const container of document.querySelectorAll("[data-link-previews]")) {
  container.addEventListener("mouseover", (event) => {
    const link = linkFor(event)

    if (link) {
      show(link)
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
  if (!popups.has(link)) {
    popups.set(link, createPopup(previews[link.getAttribute("href")!]))
  }

  const popup = popups.get(link)!

  if (!popup.matches(":popover-open")) {
    popup.showPopover()
  }

  position(popup, link)
}

function hide(link: HTMLAnchorElement) {
  const popup = popups.get(link)

  if (popup?.matches(":popover-open")) {
    popup.hidePopover()
  }
}

function createPopup(preview: LinkPreview) {
  const popup = element("div", "popup")
  const container = element("div", "popup__container")
  const content = element("div", "popup__container__content")
  const linkPreview = element("div", "link-preview")
  const text = element("div", "link-preview__text")
  const title = element("h6")
  const description = element("p")

  title.textContent = preview.title ?? ""
  description.textContent = preview.description ?? ""
  text.append(title, description)
  linkPreview.append(text)

  if (preview.image) {
    const image = element("img", "link-preview__image") as HTMLImageElement
    image.src = preview.image.src
    image.alt = ""

    if (preview.image.width && preview.image.height) {
      image.width = preview.image.width
      image.height = preview.image.height
    }

    if (preview.image.placeholder) {
      image.classList.add("placeholder")
      image.style.cssText = preview.image.placeholder
    }

    linkPreview.append(image)
  }

  content.append(linkPreview)
  container.append(element("div", "popup__container__arrow"), content)
  popup.append(container)
  popup.popover = "manual"
  document.body.append(popup)

  return popup
}

// Below the link's last line or above its first, so a link that wraps is never covered
function position(popup: HTMLElement, link: HTMLAnchorElement) {
  const container = popup.querySelector<HTMLElement>(".popup__container")!
  const arrow = popup.querySelector<HTMLElement>(".popup__container__arrow")!
  const lines = [ ...link.getClientRects() ]
  const lastLine = lines[lines.length - 1]

  let line, top
  if (window.innerHeight - lastLine.bottom >= popup.offsetHeight + VIEWPORT_MARGIN) {
    popup.dataset.placement = "bottom"
    line = lastLine
    top = lastLine.bottom
  } else {
    popup.dataset.placement = "top"
    line = lines[0]
    top = lines[0].top - popup.offsetHeight
  }

  const viewportWidth = document.documentElement.clientWidth
  const center = line.left + line.width / 2
  const left = Math.min(Math.max(center - popup.offsetWidth / 2, 0), viewportWidth - popup.offsetWidth)

  popup.style.left = `${left + window.scrollX}px`
  popup.style.top = `${top + window.scrollY}px`

  const arrowLeft = center - left - container.offsetLeft
  arrow.style.left = `${Math.min(Math.max(arrowLeft, ARROW_INSET), container.offsetWidth - ARROW_INSET)}px`
}

function element(tag: string, ...classes: string[]) {
  const node = document.createElement(tag)
  node.classList.add(...classes)
  return node
}

export {}
