// Shows a preview of a link's destination when hovering over links in an
// article. The previews are fetched at build time and embedded in the page.

const HIDDEN_CLASS = "hidden"
const VIEWPORT_MARGIN = 8

interface LinkPreview {
  title?: string
  description?: string
  image?: string
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
      popups.get(link)?.classList.add(HIDDEN_CLASS)
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
    popups.set(link, createPopup(link, previews[link.getAttribute("href")!]))
  }

  const popup = popups.get(link)!
  popup.classList.remove(HIDDEN_CLASS)
  position(link, popup)
}

function createPopup(link: HTMLAnchorElement, preview: LinkPreview) {
  const popup = element("div", "popup", HIDDEN_CLASS)
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
    image.src = preview.image
    image.alt = ""
    linkPreview.append(image)
  }

  content.append(linkPreview)
  container.append(element("div", "popup__container__arrow"), content)
  popup.append(container)

  link.style.position = "relative"
  link.append(popup)

  return popup
}

function position(link: HTMLAnchorElement, popup: HTMLElement) {
  const arrow = popup.querySelector<HTMLElement>(".popup__container__arrow")!
  const linkRect = link.getBoundingClientRect()
  const popupRect = popup.getBoundingClientRect()
  const spaceBelow = window.innerHeight - linkRect.bottom
  let placement = "top"

  if (spaceBelow >= popupRect.height + VIEWPORT_MARGIN) {
    placement = "bottom"
  }

  popup.style.position = "absolute"
  popup.style.left = "50%"
  popup.style.transform = "translateX(-50%)"
  popup.dataset.placement = placement

  if (placement === "bottom") {
    popup.style.top = "100%"
    popup.style.bottom = "auto"
  } else {
    popup.style.bottom = "100%"
    popup.style.top = "auto"
  }

  arrow.style.left = "50%"
  arrow.style.translate = "-50%"

  requestAnimationFrame(() => clampToViewport(popup, arrow))
}

function clampToViewport(popup: HTMLElement, arrow: HTMLElement) {
  const rect = popup.getBoundingClientRect()
  let shift = 0

  if (rect.right > window.innerWidth - VIEWPORT_MARGIN) {
    shift = window.innerWidth - VIEWPORT_MARGIN - rect.right
  } else if (rect.left < VIEWPORT_MARGIN) {
    shift = VIEWPORT_MARGIN - rect.left
  }

  if (shift !== 0) {
    popup.style.transform = `translateX(calc(-50% + ${shift}px))`
    arrow.style.translate = `calc(-50% - ${shift}px)`
  }
}

function element(tag: string, ...classes: string[]) {
  const node = document.createElement(tag)
  node.classList.add(...classes)
  return node
}

export {}
