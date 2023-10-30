import ApplicationController from "controllers/application_controller"

// This controller is used to implement infinite scrolling. It works by
// observing when the pagination controls are visible in the viewport, and
// then loading the next page of results.
// On the server side, the controller will need to respond with a turbo stream
// that appends the next page of results to the current one, and that also
// replaces the pagination controls with the next set of pagination controls.
export default class extends ApplicationController {
  static targets = [
    "nextButton",
    "paginationControls",
    "loadingIndicator"
  ]

  initialize() {
    const observerOptions = {
      root: null,
      rootMargin: "400px",
      threshold: 0
    }

    this.intersectionObserver = new IntersectionObserver(entries => {
      if (entries.some(entry => entry.isIntersecting)) {
        return this.loadMore()
      }
    }, observerOptions)
  }

  paginationControlsTargetConnected(target) {
    this.intersectionObserver.observe(target)
  }

  paginationControlsTargetDisconnected(target) {
    this.intersectionObserver.unobserve(target)
  }

  disconnect() {
    this.intersectionObserver.disconnect()
  }

  loadMore(event) {
    event?.preventDefault()

    // We can't load more pages if there isn't a next button
    if (!this.hasNextButtonTarget) {
      // Hide the pagination controls since we don't want to show a "previous"
      // button when we have scrolled to the end
      if (this.hasPaginationControlsTarget) this.paginationControlsTarget.style.display = "none"

      return
    }

    // If there is a loading indicator template, replace the pagination controls
    // with it so that the person scrolling can't navigate pages, and so that
    // they know that the next page is loading.
    this.showLoadingIndicator()

    // Fetch the next page of results
    fetch(this.nextButtonTarget.href, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html"
      },
      method: "GET"
    }).then(response => {
      return response.text()
    }).then(response => {
      Turbo.renderStreamMessage(response)
    }).catch(error => {
      console.error(error)
    })
  }

  showLoadingIndicator() {
    if (!this.hasLoadingIndicatorTarget || !this.hasPaginationControlsTarget) return

    this.paginationControlsTarget.style.display = "none"
    this.loadingIndicatorTarget.style.display = null
  }
}
