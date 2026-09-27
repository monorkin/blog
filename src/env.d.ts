// The bindings the on-demand routes use. Declared by hand because the types
// `wrangler types` generates replace the DOM types the browser scripts need.
declare module "cloudflare:workers" {
  export const env: {
    ASSETS: {
      fetch(input: URL | Request | string): Promise<Response>
    }
  }
}
