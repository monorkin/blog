xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  cache([ :sitemap_articles, @articles.count, @articles.maximum(:updated_at) ]) do
    @articles.find_each do |article|
      cache(article) do
        xml.url do
          xml.loc article_url(article)
          xml.lastmod article.updated_at.iso8601
          xml.priority 0.75
        end
      end
    end
  end
end
