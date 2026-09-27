const UNHIGHLIGHTED_LANGUAGES = [ "plaintext", "txt", "text", "" ]

// Shapes Shiki's output like the Rails app's Rouge output: a bare
// <pre class="highlight" data-language="…"> holding the token spans, colored
// through the CSS variables in highlight.css. Code blocks without a language
// stay plain <pre>s, as they were in Rails.
export const codeBlockTransformer = {
  name: "code-block-classes",
  pre(node) {
    const language = this.options.lang

    delete node.properties.style
    delete node.properties.tabindex
    delete node.properties.dataLanguage
    node.properties.class = []

    if (!UNHIGHLIGHTED_LANGUAGES.includes(language)) {
      node.properties.class = [ "highlight" ]
      node.properties.dataLanguage = language
    }

    node.children = node.children.flatMap(child => {
      if (child.type === "element" && child.tagName === "code") {
        return child.children
      } else {
        return [ child ]
      }
    })
  }
}
