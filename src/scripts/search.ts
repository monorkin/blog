const DIALOG_ID = "search-dialog"
const DEBOUNCE_DELAY = 150
const MAX_RESULTS = 12
const PAGEFIND_URL = "/pagefind/pagefind.js"

const MESSAGES = {
  prompt: "Finds articles, talks and snaps. Start with # to find everything with a tag, like #ruby. Press / anywhere to search.",
  unavailable: "Search works once the site is built. Run bin/preview to try it."
}

const DATE_FORMAT = new Intl.DateTimeFormat("en", { month: "short", year: "numeric", timeZone: "UTC" })

interface Pagefind {
  search(term: string | null, options?: { filters?: Record<string, string> }): Promise<{ results: PagefindResult[] }>
}

interface PagefindResult {
  data(): Promise<{ url: string, excerpt: string, meta: { title: string, type: string, date?: string } }>
}

interface Result {
  title: string
  kind: string
  date?: string
  excerpt: string
  path: string
}

let pagefind: Promise<Pagefind> | undefined

class SearchPanel {
  #input: HTMLInputElement
  #status: HTMLElement
  #results: HTMLElement
  #template: HTMLTemplateElement
  #timer?: number
  #selectedIndex = -1

  constructor(element: HTMLElement) {
    this.#input = element.querySelector("[data-search-input]")!
    this.#status = element.querySelector("[data-search-status]")!
    this.#results = element.querySelector("[data-search-results]")!
    this.#template = element.querySelector("[data-search-result-template]")!

    this.#input.addEventListener("input", () => this.#searchLater())
    this.#input.addEventListener("keydown", (event) => this.#navigate(event))
    this.#results.addEventListener("mousemove", (event) => this.#highlightUnderPointer(event))
    element.querySelector("[data-search-form]")!.addEventListener("submit", (event) => {
      event.preventDefault()
      this.search()
    })

    this.#showMessage(MESSAGES.prompt)
  }

  focus() {
    this.#input.focus()
    this.#input.select()
  }

  fill(term: string) {
    this.#input.value = term
    this.search()
  }

  async search() {
    const term = this.#input.value.trim()

    if (term === "") {
      this.#showMessage(MESSAGES.prompt)
    } else {
      try {
        const results = await findResults(term)

        if (this.#input.value.trim() === term) {
          this.#showResults(term, results)
        }
      } catch {
        this.#showMessage(MESSAGES.unavailable)
      }
    }
  }

  #searchLater() {
    clearTimeout(this.#timer)
    this.#timer = window.setTimeout(() => this.search(), DEBOUNCE_DELAY)
  }

  #showMessage(message: string) {
    this.#status.textContent = message
    this.#results.replaceChildren()
    this.#select(-1)
  }

  #showResults(term: string, results: Result[]) {
    if (results.length === 0) {
      this.#showMessage(`Nothing matches “${term}”. Try fewer words, or a tag like #rails.`)
    } else {
      this.#status.textContent = ""
      this.#results.replaceChildren(...results.map((result, index) => this.#resultItem(result, index)))
      this.#select(0)
    }
  }

  #resultItem(result: Result, index: number) {
    const item = this.#template.content.firstElementChild!.cloneNode(true) as HTMLElement
    const date = item.querySelector<HTMLTimeElement>("[data-date]")!

    item.id = `${this.#results.id}-${index}`
    item.querySelector("a")!.href = result.path
    item.querySelector("[data-title]")!.textContent = result.title
    item.querySelector("[data-kind]")!.textContent = result.kind
    item.querySelector("[data-excerpt]")!.append(...excerptNodes(result.excerpt))

    if (result.date) {
      date.dateTime = result.date
      date.textContent = DATE_FORMAT.format(new Date(result.date))
    } else {
      date.remove()
    }

    return item
  }

  #navigate(event: KeyboardEvent) {
    this.#keyHandlers[event.key]?.call(this, event)
  }

  #keyHandlers: Record<string, (this: SearchPanel, event: KeyboardEvent) => void> = {
    ArrowDown(event) {
      event.preventDefault()
      this.#moveSelection(1)
    },
    ArrowUp(event) {
      event.preventDefault()
      this.#moveSelection(-1)
    },
    Enter(event) {
      const item = this.#items[this.#selectedIndex]

      if (item && !event.isComposing) {
        event.preventDefault()
        item.querySelector("a")!.click()
      }
    },
    // A search field eats Escape to clear itself, so the dialog would stay open
    Escape(event) {
      const dialog = this.#input.closest("dialog")

      if (dialog) {
        event.preventDefault()
        dialog.close()
      }
    }
  }

  #moveSelection(step: number) {
    const count = this.#items.length

    if (count > 0) {
      this.#select((this.#selectedIndex + step + count) % count)
      this.#items[this.#selectedIndex].scrollIntoView({ block: "nearest" })
    }
  }

  #highlightUnderPointer(event: MouseEvent) {
    const item = (event.target as HTMLElement).closest<HTMLElement>(".search__result")

    if (item) {
      this.#select(this.#items.indexOf(item))
    }
  }

  #select(index: number) {
    this.#items.forEach((item, itemIndex) => item.setAttribute("aria-selected", String(itemIndex === index)))
    this.#selectedIndex = index
    this.#input.setAttribute("aria-expanded", String(this.#items.length > 0))

    if (index >= 0) {
      this.#input.setAttribute("aria-activedescendant", this.#items[index].id)
    } else {
      this.#input.removeAttribute("aria-activedescendant")
    }
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

  const results = await Promise.all(search.results.slice(0, MAX_RESULTS).map(result => result.data()))

  return results.map(result => resultFrom(result))
}

function loadPagefind() {
  if (!pagefind) {
    if (import.meta.env.DEV) {
      pagefind = Promise.reject(new Error("The Pagefind index only exists in a build"))
    } else {
      pagefind = import(/* @vite-ignore */ PAGEFIND_URL)
    }
  }

  return pagefind
}

function resultFrom({ url, excerpt, meta }: Awaited<ReturnType<PagefindResult["data"]>>): Result {
  const path = url.replace(/\.html$/, "")

  if (meta.type === "Tag") {
    return { title: `#${meta.title}`, kind: "Tag", excerpt: "", path }
  } else {
    return { title: meta.title, kind: meta.type, date: meta.date, excerpt, path }
  }
}

// Pagefind's excerpts are escaped text with <mark>s; only those two make it into the page
function excerptNodes(excerpt: string) {
  const parsed = new DOMParser().parseFromString(excerpt, "text/html")

  return [ ...parsed.body.childNodes ].map(node => {
    if (node.nodeName === "MARK") {
      const mark = document.createElement("mark")
      mark.textContent = node.textContent
      return mark
    } else {
      return document.createTextNode(node.textContent ?? "")
    }
  })
}

function openSearch() {
  const dialog = document.getElementById(DIALOG_ID) as HTMLDialogElement

  if (!dialog.open) {
    document.querySelectorAll<HTMLDialogElement>("dialog[open]").forEach(open => open.close())
    dialog.showModal()
  }

  dialogPanel.focus()
}

function opensSearch(event: KeyboardEvent) {
  const commandK = event.key === "k" && (event.ctrlKey || event.metaKey)
  const slash = event.key === "/" && !event.ctrlKey && !event.metaKey && !event.altKey && !isTyping(event.target as HTMLElement)

  return !event.defaultPrevented && !event.isComposing && (commandK || slash)
}

function isTyping(target: HTMLElement) {
  return Boolean(target.closest("input, textarea, select, [contenteditable]"))
}

const panels = new Map([ ...document.querySelectorAll<HTMLElement>("[data-search]") ].map(element => [ element, new SearchPanel(element) ]))
const dialogPanel = panels.get(document.querySelector<HTMLElement>(`#${DIALOG_ID} [data-search]`)!)!

document.addEventListener("keydown", (event) => {
  if (opensSearch(event)) {
    event.preventDefault()
    openSearch()
  }
})

document.addEventListener("click", (event) => {
  if ((event.target as HTMLElement).closest("[data-search-open]")) {
    event.preventDefault()
    openSearch()
  }
})

const initialTerm = new URLSearchParams(window.location.search).get("search[term]")

if (initialTerm && window.location.pathname === "/search") {
  panels.forEach(panel => panel.fill(initialTerm))
}
