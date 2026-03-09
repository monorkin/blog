xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  cache([ :sitemap_tags, @tags.count, @tags.maximum(:updated_at) ]) do
    @tags.each do |tag|
      cache(tag) do
        xml.url do
          xml.loc tag_url(tag)
          xml.lastmod tag.updated_at.iso8601
          xml.priority 0.7
        end
      end
    end
  end
end
