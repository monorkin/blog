declare global {
  interface Window {
    colorScheme: { readonly current: string, use(scheme: string): void }
  }
}

const inputs = document.querySelectorAll<HTMLInputElement>("[data-settings] input[data-color-scheme]")

for (const input of inputs) {
  input.addEventListener("change", () => {
    window.colorScheme.use(input.dataset.colorScheme!)
    markCurrentScheme()
  })
}

markCurrentScheme()

function markCurrentScheme() {
  for (const input of inputs) {
    input.checked = input.dataset.colorScheme === window.colorScheme.current
  }
}

export {}
