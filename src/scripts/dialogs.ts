const SEARCH_DIALOG_ID = "search-dialog"

document.addEventListener("click", (event) => {
  const target = event.target as HTMLElement
  const opener = target.closest<HTMLElement>("[data-dialog-open]")
  const closer = target.closest<HTMLElement>("[data-dialog-close]")

  if (opener) {
    event.preventDefault()
    openDialog(opener.dataset.dialogOpen!)
  } else if (closer?.closest("dialog")) {
    event.preventDefault()
    closer.closest("dialog")!.close()
  } else if (target instanceof HTMLDialogElement && target.hasAttribute("data-dismissable") && isOutside(target, event)) {
    target.close()
  }
})

document.addEventListener("keydown", (event) => {
  if (event.key === "k" && (event.ctrlKey || event.metaKey) && !event.defaultPrevented) {
    event.preventDefault()
    openDialog(SEARCH_DIALOG_ID)
  }
})

document.addEventListener("close", () => {
  if (!document.querySelector("dialog[open]")) {
    document.body.classList.remove("overflow-hidden")
  }
}, true)

export function openDialog(id: string) {
  const dialog = document.getElementById(id) as HTMLDialogElement

  dialog.showModal()
  document.body.classList.add("overflow-hidden")
  dialog.querySelector<HTMLInputElement>("[data-search-input]")?.focus()
}

function isOutside(dialog: HTMLDialogElement, { clientX, clientY }: MouseEvent) {
  const bounds = dialog.getBoundingClientRect()

  return clientY < bounds.top || clientY > bounds.bottom || clientX < bounds.left || clientX > bounds.right
}
