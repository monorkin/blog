function configureTrix() {
  useH2Headings()
}

function useH2Headings() {
  Trix.config.blockAttributes.heading1.tagName = "h2"
}

import Trix from "trix2"
configureTrix()
import "@rails/actiontext"
