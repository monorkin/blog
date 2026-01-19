# frozen_string_literal: true

module SEOHelper
  def seo_meta_tags(title:, description:, image: nil, type: 'website', url: nil)
    full_title = "#{title} | Stanko K.R."
    canonical_url = url || url_for(only_path: false)
    image_url = image || asset_url('portrait/medium.jpg')

    [
      content_tag(:meta, nil, name: 'description', content: description),
      content_tag(:link, nil, rel: 'canonical', href: canonical_url),
      content_tag(:meta, nil, name: 'twitter:card', content: 'summary'),
      content_tag(:meta, nil, name: 'twitter:creator', content: '@monorkin'),
      content_tag(:meta, nil, name: 'twitter:title', content: full_title),
      content_tag(:meta, nil, name: 'twitter:description', content: description),
      content_tag(:meta, nil, name: 'twitter:image', content: image_url),
      content_tag(:meta, nil, property: 'og:title', content: full_title),
      content_tag(:meta, nil, property: 'og:description', content: description),
      content_tag(:meta, nil, property: 'og:locale', content: 'en_US'),
      content_tag(:meta, nil, property: 'og:type', content: type),
      content_tag(:meta, nil, property: 'og:url', content: canonical_url),
      content_tag(:meta, nil, property: 'og:image', content: image_url)
    ]
  end

  def noindex_meta_tag
    content_tag(:meta, nil, name: 'robots', content: 'noindex, nofollow')
  end
end
