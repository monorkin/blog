// Images in a gallery are shown side by side, too small to read a screenshot, so clicking
// one opens it full size in a lightbox, with the arrow keys moving through the gallery.

let lightbox: HTMLDialogElement | undefined
let figures: HTMLElement[] = []
let current = 0

document.addEventListener("click", (event) => {
  const figure = (event.target as HTMLElement).closest<HTMLElement>(".attachment-gallery .attachment")

  if (figure) {
    figures = [ ...figure.closest(".attachment-gallery")!.querySelectorAll<HTMLElement>(".attachment") ]
    show(figures.indexOf(figure))
    lightboxElement().showModal()
    document.body.classList.add("overflow-hidden")
  }
})

document.addEventListener("keydown", (event) => {
  if (lightbox?.open && event.key === "ArrowLeft") {
    show(current - 1)
  } else if (lightbox?.open && event.key === "ArrowRight") {
    show(current + 1)
  }
})

function show(index: number) {
  current = (index + figures.length) % figures.length

  const figure = figures[current]
  const image = figure.querySelector("img")!
  const shown = lightboxElement().querySelector<HTMLImageElement>(".lightbox__image")!

  shown.src = figure.dataset.fullSrc!
  shown.alt = image.alt
  lightboxElement().querySelector(".lightbox__caption")!.textContent = figure.querySelector("figcaption")!.textContent
  lightboxElement().querySelectorAll<HTMLElement>(".lightbox__nav").forEach(button => button.hidden = figures.length < 2)
}

function lightboxElement() {
  if (!lightbox) {
    lightbox = buildLightbox()
    document.body.append(lightbox)
  }

  return lightbox
}

function buildLightbox() {
  const dialog = element("dialog", "lightbox") as HTMLDialogElement
  const frame = element("div", "dialog__frame")
  const content = element("div", "lightbox__content")
  const close = button("lightbox__close", "×", "Close")
  const previous = button("lightbox__nav lightbox__nav--prev", "‹", "Previous")
  const next = button("lightbox__nav lightbox__nav--next", "›", "Next")
  const footer = element("div", "lightbox__footer")
  const captions = element("div", "lightbox__captions")

  close.dataset.dialogClose = ""
  previous.addEventListener("click", () => show(current - 1))
  next.addEventListener("click", () => show(current + 1))
  captions.append(element("span", "lightbox__caption"))
  footer.append(captions)
  content.append(close, previous, element("img", "lightbox__image"), next, footer)
  frame.append(content)
  dialog.append(frame)
  dialog.setAttribute("aria-label", "Image")

  return dialog
}

function button(classes: string, label: string, name: string) {
  const node = element("button", ...classes.split(" "))
  node.textContent = label
  node.setAttribute("aria-label", name)
  return node
}

function element(tag: string, ...classes: string[]) {
  const node = document.createElement(tag)
  node.classList.add(...classes)
  return node
}

export {}
