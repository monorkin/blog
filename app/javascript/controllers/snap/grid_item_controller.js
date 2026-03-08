import ApplicationController from "controllers/application_controller"

const MAX_ROTATION = 8
const TRANSITION_DURATION = "0.15s"

export default class extends ApplicationController {
  // Actions

  rotate({ currentTarget, clientX, clientY }) {
    const rect = currentTarget.getBoundingClientRect()
    const x = (clientX - rect.left) / rect.width
    const y = (clientY - rect.top) / rect.height

    const rotateY = (x - 0.5) * MAX_ROTATION * 2
    const rotateX = (0.5 - y) * MAX_ROTATION * 2

    currentTarget.style.transform = `perspective(600px) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`
    currentTarget.style.transition = `transform ${TRANSITION_DURATION} ease-out`
  }

  reset({ currentTarget }) {
    currentTarget.style.transform = ""
    currentTarget.style.transition = `transform 0.3s ease-out`
  }
}
