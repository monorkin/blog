function configureTrix() {
  useParagraphs()
  useH2Headings()
}

function useParagraphs() {
  Trix.config.blockAttributes.default.tagName = "p"
  Trix.config.blockAttributes.default.breakOnReturn = true;

  Trix.Block.prototype.breaksOnReturn = function() {
    const attr = this.getLastAttribute()
    const config = Trix.config.blockAttributes[attr ? attr : "default"]
    return config ? config.breakOnReturn : false
  }

  Trix.LineBreakInsertion.prototype.shouldInsertBlockBreak = function() {
    if(this.block.hasAttributes() && this.block.isListItem() && !this.block.isEmpty()) {
      return this.startLocation.offset > 0
    } else {
      return !this.shouldBreakFormattedBlock() ? this.breaksOnReturn : false
    }
  }
}

function useH2Headings() {
  Trix.config.blockAttributes.heading1.tagName = "h2"
}

import Trix from "trix2"
configureTrix()
import "@rails/actiontext"
