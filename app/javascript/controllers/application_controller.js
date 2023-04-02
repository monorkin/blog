import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  appendTokenTo(token, tokenListString) {
    if (!tokenListString || tokenListString.length == 0) return token
    if (tokenListString.includes(token)) return tokenListString

    return `${tokenListString} ${token}`
  }
}
