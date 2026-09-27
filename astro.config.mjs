import { defineConfig, envField } from "astro/config"
import cloudflare from "@astrojs/cloudflare"
import mdx from "@astrojs/mdx"
import { satteri } from "@astrojs/markdown-satteri"
import { fileURLToPath } from "node:url"
import { codeBlockTransformer } from "./src/lib/code-blocks.js"
import { mediaHandler } from "./lib/media-server.js"

// astro dev serves media/ at /media, so bin/dev works offline with MEDIA_URL=/media
const localMedia = {
  name: "local-media",
  hooks: {
    "astro:server:setup": ({ server }) => {
      server.middlewares.use("/media", mediaHandler(fileURLToPath(new URL("./media", import.meta.url))))
    }
  }
}

export default defineConfig({
  site: "https://stanko.io",
  trailingSlash: "never",
  compressHTML: true,
  session: false,
  build: {
    format: "file"
  },
  env: {
    schema: {
      MEDIA_URL: envField.string({ context: "server", access: "public", default: "https://media.stanko.io" })
    }
  },
  adapter: cloudflare({
    imageService: "compile",
    prerenderEnvironment: "node"
  }),
  integrations: [ mdx(), localMedia ],
  markdown: {
    processor: satteri({ features: { smartPunctuation: false } }),
    shikiConfig: {
      theme: "css-variables",
      transformers: [ codeBlockTransformer ]
    }
  }
})
