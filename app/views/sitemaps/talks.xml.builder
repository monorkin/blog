xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @talks.find_each do |talk|
    xml.url do
      xml.loc talk_url(talk)
      xml.lastmod talk.updated_at.iso8601
      xml.priority 0.75
    end
  end
end
