export interface ProjectPage {
  url: string
  frontmatter: { title: string, description: string, draft?: boolean }
}

const pages = Object.values(import.meta.glob<ProjectPage>("/src/pages/projects/*.{md,mdx}", { eager: true }))

// Draft project pages still build, since every page in src/pages does, but they aren't
// listed or in the sitemap, and ask search engines to leave them alone
export function listedProjects() {
  return pages
    .filter(page => !page.frontmatter.draft)
    .sort((a, b) => a.frontmatter.title.localeCompare(b.frontmatter.title))
}
