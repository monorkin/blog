# frozen_string_literal: true

module ArticleHelper
  def article_image_tag(image, options = {})
    image_url = image.image_url(:large) || image.image_url
    options = options.merge(loading: 'lazy', srcset: image.srcset)

    image_tag(image_url, options)
  end
end
