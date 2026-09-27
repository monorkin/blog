import type { PaginateFunction } from "astro"
import { PAGE_SIZE } from "~/lib/site"

export interface IndexPage<T> {
  data: T[]
  number: number
  first: boolean
  last: boolean
  nextUrl?: string
}

// Pages after the first live at `<base>/page/<number>`. A bare `<base>/<number>`
// would collide with the Rails app's numeric talk URLs, which still redirect.
export function paginateIndex<T>(paginate: PaginateFunction, items: T[], basePath: string, params: Record<string, string> = {}) {
  return paginate(items, { pageSize: PAGE_SIZE, params }).map(({ props: { page } }) => {
    const indexPage: IndexPage<T> = {
      data: page.data,
      number: page.currentPage,
      first: page.currentPage === 1,
      last: page.currentPage === page.lastPage,
      nextUrl: nextPagePath(basePath, page.currentPage, page.lastPage)
    }

    return { params: { ...params, page: pageParam(page.currentPage) }, props: { page: indexPage } }
  })
}

export function pagePath(basePath: string, number: number) {
  if (number === 1) {
    return basePath
  } else {
    return `${basePath}/page/${number}`
  }
}

function nextPagePath(basePath: string, current: number, last: number) {
  if (current < last) {
    return pagePath(basePath, current + 1)
  }
}

function pageParam(number: number) {
  if (number === 1) {
    return undefined
  } else {
    return `page/${number}`
  }
}
