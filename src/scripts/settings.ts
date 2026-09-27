declare global {
  interface Window {
    colorScheme: { readonly current: string, use(scheme: string): void }
  }
}

const VIEWPORT_MARGIN = 8

const inputs = document.querySelectorAll<HTMLInputElement>("[data-appearance] input[data-color-scheme]")
const popover = document.getElementById("appearance-popover")!

for (const input of inputs) {
  input.addEventListener("change", () => {
    window.colorScheme.use(input.dataset.colorScheme!)
    markCurrentScheme()
  })
}

// Opens under the button that toggles it, right edges lined up
popover.addEventListener("beforetoggle", (event) => {
  if ((event as ToggleEvent).newState === "open") {
    placeUnder(document.querySelector(`[popovertarget="${popover.id}"]`)!)
  }
})

markCurrentScheme()

function markCurrentScheme() {
  for (const input of inputs) {
    input.checked = input.dataset.colorScheme === window.colorScheme.current
  }
}

function placeUnder(button: HTMLElement) {
  const rect = button.getBoundingClientRect()
  const right = document.documentElement.clientWidth - rect.right

  popover.style.top = `${rect.bottom + window.scrollY + VIEWPORT_MARGIN}px`
  popover.style.right = `${Math.max(right, VIEWPORT_MARGIN)}px`
}

export {}
