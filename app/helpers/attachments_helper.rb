# frozen_string_literal: true

module AttachmentsHelper
  def attachment_image_tag(source, alt:, size:)
    width, height = size
    options = {
      alt: alt,
      loading: "lazy",
      class: "attachment__image",
      data: {
        controller: "image",
        action: "load->image#markLoaded error->image#markLoaded",
        image_loaded_class: "attachment__image--loaded"
      }
    }
    options.merge!(width: width, height: height) if width.positive? && height.positive?

    image_tag(source, **options)
  end

  def resized_image_size(width, height, limit)
    if width.positive? && height.positive?
      max_width, max_height = limit
      scale = [ 1.0, max_width.fdiv(width), (max_height || height).fdiv(height) ].min

      [ (width * scale).round, (height * scale).round ]
    else
      [ width, height ]
    end
  end
end
