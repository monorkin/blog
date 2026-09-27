// Loads the next page of an index when its "Load more" link scrolls into view, or is
// clicked, and puts that page's content in place of the link. If loading fails, the link
// stays, so clicking it tries again (or, without this script, opens the next page).

const PRELOAD_MARGIN = "400px"

const loading = new WeakSet<HTMLAnchorElement>()

const observer = new IntersectionObserver((entries) => {
  for (const entry of entries) {
    if (entry.isIntersecting) {
      loadPage(entry.target as HTMLAnchorElement)
    }
  }
}, { rootMargin: PRELOAD_MARGIN })

document.addEventListener("click", (event) => {
  const link = (event.target as HTMLElement).closest<HTMLAnchorElement>("a.pagination__trigger")

  if (link) {
    event.preventDefault()
    loadPage(link)
  }
})

observeTriggersIn(document)

async function loadPage(link: HTMLAnchorElement) {
  if (!loading.has(link)) {
    loading.add(link)
    observer.unobserve(link)

    try {
      showPage(link, await fetchPage(link.href))
    } catch {
      loading.delete(link)
    }
  }
}

async function fetchPage(url: string) {
  const response = await fetch(url)

  if (response.ok) {
    return new DOMParser().parseFromString(await response.text(), "text/html")
  } else {
    throw new Error(`${url} answered ${response.status}`)
  }
}

function showPage(link: HTMLAnchorElement, page: Document) {
  const content = page.querySelector("[data-pagination-page]")!
  const wrapper = document.createElement("div")

  wrapper.className = "pagination__page"
  wrapper.append(...content.childNodes)
  link.replaceWith(wrapper)
  observeTriggersIn(wrapper)
  document.dispatchEvent(new CustomEvent("pagination:load", { detail: { element: wrapper } }))
}

function observeTriggersIn(element: ParentNode) {
  for (const link of element.querySelectorAll<HTMLAnchorElement>("a.pagination__trigger")) {
    observer.observe(link)
  }
}
