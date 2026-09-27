// Serves media/ from disk, for development: astro dev mounts it at /media, and
// `bin/media serve` runs it on a port of its own for bin/preview.
import { createReadStream, existsSync, statSync } from "node:fs"
import { extname, join, sep } from "node:path"

const TYPES = {
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png",
  ".webp": "image/webp",
  ".gif": "image/gif",
  ".svg": "image/svg+xml",
  ".mp4": "video/mp4",
  ".webm": "video/webm",
  ".mov": "video/quicktime"
}

export function mediaHandler(root) {
  return (request, response) => {
    const path = join(root, decodeURIComponent(new URL(request.url, "http://localhost").pathname))

    if (path.startsWith(root + sep) && existsSync(path) && statSync(path).isFile()) {
      sendFile(path, request, response)
    } else {
      response.writeHead(404).end()
    }
  }
}

// Browsers ask for videos in ranges, and won't let you seek without it
function sendFile(path, request, response) {
  const size = statSync(path).size
  const type = TYPES[extname(path).toLowerCase()] ?? "application/octet-stream"
  const range = request.headers.range?.match(/bytes=(\d*)-(\d*)/)

  if (range) {
    const start = Number(range[1] || 0)
    const end = Math.min(Number(range[2] || size - 1), size - 1)
    response.writeHead(206, { "Content-Type": type, "Content-Length": end - start + 1, "Content-Range": `bytes ${start}-${end}/${size}`, "Accept-Ranges": "bytes" })
    createReadStream(path, { start, end }).pipe(response)
  } else {
    response.writeHead(200, { "Content-Type": type, "Content-Length": size, "Accept-Ranges": "bytes" })
    createReadStream(path).pipe(response)
  }
}
