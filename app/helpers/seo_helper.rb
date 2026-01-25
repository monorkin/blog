# frozen_string_literal: true

module SEOHelper
  def seo_meta_tags(title:, description:, image:, type: "website", url: nil)
    canonical_url = url || url_for(only_path: false)

    safe_join([
      tag.meta(name: "description", content: description),
      tag.link(rel: "canonical", href: canonical_url),
      tag.meta(name: "twitter:card", content: "summary"),
      tag.meta(name: "twitter:creator", content: "@monorkin"),
      tag.meta(name: "twitter:title", content: title),
      tag.meta(name: "twitter:description", content: description),
      tag.meta(name: "twitter:image", content: image[:url]),
      tag.meta(property: "og:title", content: title),
      tag.meta(property: "og:description", content: description),
      tag.meta(property: "og:locale", content: "en_US"),
      tag.meta(property: "og:type", content: type),
      tag.meta(property: "og:url", content: canonical_url),
      tag.meta(property: "og:image", content: image[:url]),
      (tag.meta(property: "og:image:width", content: image[:width]) if image[:width]),
      (tag.meta(property: "og:image:height", content: image[:height]) if image[:height])
    ].compact, "\n")
  end

  def seo_meta_tags_for_entry(entry)
    seo = entry.seo

    seo_meta_tags(
      title: seo.title,
      description: seo.description,
      type: seo.og_type,
      image: seo.image.to_h,
      url: seo.canonical_url
    )
  end

  def noindex_meta_tag
    tag.meta(name: "robots", content: "noindex, nofollow")
  end
end
