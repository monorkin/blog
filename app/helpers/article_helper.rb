# frozen_string_literal: true

module ArticleHelper
  def article_image_tag(image, options = {})
    image_url = image.image_url(:large) || image.image_url
    options = options.merge(loading: 'lazy', srcset: image.srcset)
    options[:style] = [options.fetch(:style, ''), "--image-aspect-ratio: #{image.aspect_ratio}"].compact.join('; ')

    image_tag(image_url, options)
  end

  def search_articles_with_tag_link(tag_record, options = {})
    link_to(tag_record.name,
            public_articles_url(article_search: { term: "tag:\"#{tag_record.name}\"" }),
            { class: 'pill_link pill_link--spaced' }.merge(options))
  end
end
