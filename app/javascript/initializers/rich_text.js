import "trix2"
import "@rails/actiontext"

Trix.config.blockAttributes.heading1.tagName = "h2"

const originalPreviewablePattern = Trix.Attachment.previewablePattern
Trix.Attachment.previewablePattern = new RegExp(
  originalPreviewablePattern.source + "|video/mp4|video/quicktime|video/webm",
  originalPreviewablePattern.flags
)

// const originalAttachmentSelector = Trix.config.attachments.preview.captionSelector
// Trix.config.attachments.preview.captionSelector =
//   originalAttachmentSelector + ", figcaption[data-trix-video-caption]"

const originalCreateContentNodes = Trix.views.PreviewableAttachmentView.prototype.createContentNodes
Trix.views.PreviewableAttachmentView.prototype.createContentNodes = function() {
  const original = originalCreateContentNodes.apply(this, arguments)

  if (this.attachment.getContentType().match(/^video\//)) {
    const img = original[0]
    const video = document.createElement("video")

    for (const attribute of img.attributes) {
      video.setAttribute(attribute.name, attribute.value)
    };
    video.setAttribute("controls", true)
    video.setAttribute("data-trix-video-caption", true)
    video.setAttribute("preload", "metadata")

    this.video = video

    return [video]
  }

  return original
}
