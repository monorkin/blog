// Health check, kept from the Rails app's /up route
export function GET() {
  return new Response('<!DOCTYPE html><html><body style="background-color: green"></body></html>', {
    headers: { "Content-Type": "text/html; charset=utf-8" }
  })
}
