xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc root_url
    xml.lastmod File.mtime(Rails.root.join("app/views/about/show.html.erb")).iso8601
    xml.priority 1.0
  end
  xml.url do
    xml.loc articles_url
    xml.lastmod Article.published.maximum(:updated_at)&.iso8601
    xml.priority 0.9
  end
  xml.url do
    xml.loc talks_url
    xml.lastmod Talk.maximum(:updated_at)&.iso8601
    xml.priority 0.9
  end
end
