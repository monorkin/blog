xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @articles.find_each do |article|
    xml.url do
      xml.loc article_url(article)
      xml.lastmod article.updated_at.iso8601
      xml.priority 0.75
    end
  end
end
