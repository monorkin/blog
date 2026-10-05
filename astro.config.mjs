import { defineConfig, envField } from "astro/config"
import cloudflare from "@astrojs/cloudflare"
import mdx from "@astrojs/mdx"
import { satteri } from "@astrojs/markdown-satteri"
import { spawn } from "node:child_process"
import { join, sep } from "node:path"
import { fileURLToPath } from "node:url"
import { codeBlockTransformer } from "./src/lib/code-blocks.js"
import { mediaHandler } from "./lib/media-server.js"

const MEDIA = fileURLToPath(new URL("./media", import.meta.url))
const ORIGINALS = join(MEDIA, "originals")
const BIN_MEDIA = fileURLToPath(new URL("./bin/media", import.meta.url))
// Copying a file in fires a burst of events; variants run once they've stopped for this long
const VARIANTS_DELAY = 1000

// astro dev serves media/ at /media, so bin/dev works offline with MEDIA_URL=/media, and runs
// `bin/media variants` whenever something in media/originals changes, so a new photo shows
// without a trip to the terminal
const localMedia = {
  name: "local-media",
  hooks: {
    "astro:server:setup": ({ server, logger }) => {
      server.middlewares.use("/media", mediaHandler(MEDIA))
      makeVariantsOnChange(server.watcher, logger)
    }
  }
}

function makeVariantsOnChange(watcher, logger) {
  let timer
  let running = false
  let queued = false

  const makeVariants = () => {
    if (running) {
      queued = true
    } else {
      running = true
      logger.info("media/originals changed, running bin/media variants")

      spawn(BIN_MEDIA, [ "variants" ], { stdio: "inherit" }).on("exit", code => {
        running = false

        if (code !== 0) {
          logger.error(`bin/media variants failed with exit code ${code}`)
        }

        if (queued) {
          queued = false
          makeVariants()
        }
      })
    }
  }

  watcher.add(ORIGINALS)
  watcher.on("all", (event, path) => {
    if (path.startsWith(ORIGINALS + sep)) {
      clearTimeout(timer)
      timer = setTimeout(makeVariants, VARIANTS_DELAY)
    }
  })
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
