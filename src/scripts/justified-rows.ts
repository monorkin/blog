// Breaks a justified grid's rows so that, taken together, they come closest to --row-height.
// The CSS alone breaks a row only once the next photo doesn't fit, so a wide photo can leave
// the ones before it to fill the whole row and grow far taller than the rest.
//
// Every place a row could end is weighed, like a paragraph's line breaks: a row costs more
// the further its height is from the target, more so when it's shorter, since that shrinks
// portrait photos the most, and the last row costs a little for every bit of it left empty.
//
// Each item's flex-basis is set to its width at its row's height, a little under, and the
// items' own flex-grow takes up the remaining fraction of a pixel.

const SLACK = 0.5
const SHORT_ROW_WEIGHT = 2
const EMPTY_LAST_ROW_WEIGHT = 0.5
const MIN_ROW_HEIGHT = 0.5

const observer = new ResizeObserver((entries) => {
  for (const entry of entries) {
    layout(entry.target as HTMLElement)
  }
})

export function justify(grid: HTMLElement) {
  observer.observe(grid)
}

export function layout(grid: HTMLElement) {
  const style = getComputedStyle(grid)
  const width = grid.clientWidth - parseFloat(style.paddingInlineStart) - parseFloat(style.paddingInlineEnd)
  const gap = parseFloat(style.columnGap)
  const targetHeight = parseFloat(style.getPropertyValue("--row-height"))
  const items = [ ...grid.children ] as HTMLElement[]
  const aspectRatios = items.map(aspectRatioOf)

  const heightOf = (start: number, end: number) => {
    const totalAspectRatio = aspectRatios.slice(start, end).reduce((total, ratio) => total + ratio, 0)
    return (width - gap * (end - start - 1)) / totalAspectRatio
  }

  const rowCost = (height: number, last: boolean) => {
    if (last && height >= targetHeight) {
      return EMPTY_LAST_ROW_WEIGHT * (1 - targetHeight / height) ** 2
    } else if (height < targetHeight) {
      return SHORT_ROW_WEIGHT * Math.log(height / targetHeight) ** 2
    } else {
      return Math.log(height / targetHeight) ** 2
    }
  }

  const costs = [ 0 ]
  const rowStarts = [ 0 ]

  for (let end = 1; end <= items.length; end++) {
    costs[end] = Infinity

    for (let start = end - 1; start >= 0; start--) {
      const height = heightOf(start, end)

      if (start < end - 1 && height < targetHeight * MIN_ROW_HEIGHT) {
        break
      }

      const cost = costs[start] + rowCost(height, end === items.length)

      if (cost < costs[end]) {
        costs[end] = cost
        rowStarts[end] = start
      }
    }
  }

  for (let end = items.length; end > 0; end = rowStarts[end]) {
    const start = rowStarts[end]
    const height = heightOf(start, end)

    if (end === items.length && height >= targetHeight) {
      size(items.slice(start, end), targetHeight)
    } else {
      size(items.slice(start, end), height - SLACK)
    }
  }
}

function size(row: HTMLElement[], height: number) {
  for (const item of row) {
    item.style.flexBasis = `${aspectRatioOf(item) * height}px`
  }
}

function aspectRatioOf(item: HTMLElement) {
  return parseFloat(getComputedStyle(item).getPropertyValue("--aspect-ratio"))
}
