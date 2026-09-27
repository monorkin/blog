const DEBOUNCE_DELAY = 300
const RESULTS_PER_TYPE = 5
const TYPES = [ "Article", "Talk", "Tag" ]
const PAGEFIND_URL = "/pagefind/pagefind.js"

interface Pagefind {
  search(term: string | null, options?: { filters?: Record<string, string> }): Promise<{ results: PagefindResult[] }>
}

interface PagefindResult {
  data(): Promise<{ url: string, meta: { title: string, type: string } }>
}

let pagefind: Promise<Pagefind> | undefined

class SearchPanel {
  #input: HTMLInputElement
  #results: HTMLElement
  #template: HTMLTemplateElement
  #timer?: number
  #selectedIndex = -1

  constructor(element: HTMLElement) {
    this.#input = element.querySelector("[data-search-input]")!
    this.#results = element.querySelector("[data-search-results]")!
    this.#template = element.querySelector("[data-search-result-template]")!

    this.#input.addEventListener("input", () => this.#searchLater())
    this.#input.addEventListener("keydown", (event) => this.#navigate(event))
    element.querySelector("[data-search-form]")!.addEventListener("submit", (event) => {
      event.preventDefault()
      this.search()
    })
  }

  async search() {
    const term = this.#input.value.trim()

    if (term === "") {
      this.#showMessage("Enter something in the field above and press enter")
    } else if (import.meta.env.DEV) {
      this.#showMessage("Search needs the Pagefind index, which only a build has")
    } else {
      const results = await findResults(term)

      if (this.#input.value.trim() === term) {
        this.#showResults(results)
      }
    }
  }

  fill(term: string) {
    this.#input.value = term
    this.search()
  }

  #searchLater() {
    clearTimeout(this.#timer)
    this.#timer = window.setTimeout(() => this.search(), DEBOUNCE_DELAY)
  }

  #showMessage(message: string) {
    const element = document.createElement("div")
    element.className = "search__no-results"
    element.textContent = message
    this.#results.replaceChildren(element)
    this.#selectedIndex = -1
  }

  #showResults(results: Array<{ title: string, type: string, path: string }>) {
    if (results.length === 0) {
      this.#showMessage("No results found")
    } else {
      const list = document.createElement("ul")
      list.className = "search__results-list"
      list.setAttribute("role", "listbox")
      list.append(...results.map(result => this.#resultItem(result)))
      this.#results.replaceChildren(list)
      this.#selectedIndex = -1
    }
  }

  #resultItem({ title, type, path }: { title: string, type: string, path: string }) {
    const item = this.#template.content.firstElementChild!.cloneNode(true) as HTMLElement
    const link = item.querySelector("a")!

    link.href = path
    link.setAttribute("aria-label", title)
    item.querySelector(".search__result-title")!.textContent = title
    item.querySelector(".search__result-type")!.textContent = type
    item.addEventListener("mouseenter", () => this.#highlight(this.#items.indexOf(item)))

    return item
  }

  #navigate(event: KeyboardEvent) {
    this.#keyHandlers[event.key]?.call(this, event)
  }

  #keyHandlers: Record<string, (event: KeyboardEvent) => void> = {
    ArrowDown(this: SearchPanel, event: KeyboardEvent) {
      event.preventDefault()
      this.#moveSelection(1)
    },
    ArrowUp(this: SearchPanel, event: KeyboardEvent) {
      event.preventDefault()
      this.#moveSelection(-1)
    },
    Enter(this: SearchPanel, event: KeyboardEvent) {
      const item = this.#items[this.#selectedIndex]

      if (item && !event.isComposing) {
        event.preventDefault()
        item.querySelector("a")!.click()
      }
    }
  }

  #moveSelection(step: number) {
    const count = this.#items.length

    if (count > 0) {
      this.#highlight((this.#selectedIndex + step + count) % count)
    }
  }

  #highlight(index: number) {
    this.#items.forEach((item, itemIndex) => item.setAttribute("aria-selected", String(itemIndex === index)))
    this.#selectedIndex = index
    this.#items[index]?.scrollIntoView({ block: "nearest" })
  }

  get #items() {
    return [ ...this.#results.querySelectorAll<HTMLElement>(".search__result") ]
  }
}

async function findResults(term: string) {
  const index = await loadPagefind()
  let search

  if (term.startsWith("#")) {
    search = await index.search(null, { filters: { tag: term.slice(1).toLowerCase() } })
  } else {
    search = await index.search(term)
  }

  const results = await Promise.all(search.results.slice(0, 30).map(result => result.data()))

  return TYPES.flatMap(type => {
    return results
      .filter(result => result.meta.type === type)
      .slice(0, RESULTS_PER_TYPE)
      .map(result => ({ title: result.meta.title, type, path: result.url.replace(/\.html$/, "") }))
  })
}

function loadPagefind() {
  if (!pagefind) {
    pagefind = import(/* @vite-ignore */ PAGEFIND_URL)
  }

  return pagefind
}

const panels = [ ...document.querySelectorAll<HTMLElement>("[data-search]") ].map(element => new SearchPanel(element))
const initialTerm = new URLSearchParams(window.location.search).get("search[term]")

if (initialTerm && window.location.pathname === "/search") {
  panels.forEach(panel => panel.fill(initialTerm))
}
