export default class {
  static DEFAULT_EXPIRATION_PERIOD = 5 * 365 * 24 * 60 * 60 * 1000

  static get(key) {
    const cookie = this.find(key)
    if (!cookie) return null

    const value = cookie.split("=").slice(1).join("=")
    return value ? decodeURIComponent(value) : undefined
  }

  static set(key, value, expiresAt) {
    expiresAt ||= new Date(Date.now() + this.DEFAULT_EXPIRATION_PERIOD).toUTCString()
    const cookie = `${encodeURIComponent(key)}=${encodeURIComponent(value)}; path=/; expires=${expiresAt}`
    document.cookie = cookie
    return true
  }

  static delete(key) {
    const cookie = this.find(key)
    if (!cookie) return false

    this.set(key, "", "Thu, 01 Jan 1970 00:00:01 GMT")
    return true
  }

  static get all() {
    return document.cookie ? document.cookie.split("; ") : []
  }

  static find(key) {
    const prefix = `${encodeURIComponent(key)}=`
    return this.all.find(cookie => cookie.startsWith(prefix))
  }
}
