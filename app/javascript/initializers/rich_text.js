import { configure } from "lexxy"
import "@rails/actiontext"
import JapaneseExtension from "lexxy_extensions/japanese_extension"

configure({
  global: {
    extensions: [ JapaneseExtension ]
  }
})
