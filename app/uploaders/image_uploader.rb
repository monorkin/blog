# frozen_string_literal: true

require 'image_processing/vips'

class ImageUploader < Shrine
  add_metadata :md5_digest do |io|
    calculate_signature(io, :md5)
  end

  Attacher.derivatives do |original|
    next {} if Marcel::MimeType.for(original) == 'image/gif'

    image = ImageProcessing::Vips.source(original)

    {
      large: image.resize_to_limit!(1024, 1024),
      medium: image.resize_to_limit!(512, 512),
      small: image.resize_to_limit!(256, 256),
      thumbnail: image.resize_to_limit!(32, 32)
    }
  end
end
