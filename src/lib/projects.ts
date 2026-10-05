export interface ProjectPage {
  url: string
  frontmatter: { title: string, description: string }
}

const pages = Object.values(import.meta.glob<ProjectPage>("/src/pages/projects/*.{md,mdx}", { eager: true }))

export function listedProjects() {
  return pages
    .sort((a, b) => a.frontmatter.title.localeCompare(b.frontmatter.title))
}
