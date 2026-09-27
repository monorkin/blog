// Loads the next page of an index when its "Load more" link scrolls into view
// and puts that page's content in place of the link.

const PRELOAD_MARGIN = "400px"

const observer = new IntersectionObserver((entries) => {
  for (const entry of entries) {
    if (entry.isIntersecting) {
      loadPage(entry.target as HTMLAnchorElement)
    }
  }
}, { rootMargin: PRELOAD_MARGIN })

async function loadPage(link: HTMLAnchorElement) {
  observer.unobserve(link)

  const response = await fetch(link.href)
  const page = new DOMParser().parseFromString(await response.text(), "text/html")
  const content = page.querySelector("[data-pagination-page]")

  if (content) {
    const wrapper = document.createElement("div")
    wrapper.className = "pagination__page"
    wrapper.append(...content.childNodes)
    link.replaceWith(wrapper)
    observeTriggersIn(wrapper)
    document.dispatchEvent(new CustomEvent("pagination:load", { detail: { element: wrapper } }))
  }
}

function observeTriggersIn(element: ParentNode) {
  for (const link of element.querySelectorAll<HTMLAnchorElement>("a.pagination__trigger")) {
    observer.observe(link)
  }
}

observeTriggersIn(document)
