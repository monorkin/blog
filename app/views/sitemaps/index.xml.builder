xml.instruct!
xml.sitemapindex xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.sitemap do
    xml.loc sitemap_pages_url
    xml.lastmod File.mtime(Rails.root.join('app/views/about/show.html.erb')).iso8601
  end
  xml.sitemap do
    xml.loc sitemap_articles_url
    xml.lastmod Article.published.maximum(:updated_at)&.iso8601
  end
  xml.sitemap do
    xml.loc sitemap_talks_url
    xml.lastmod Talk.maximum(:updated_at)&.iso8601
  end
  xml.sitemap do
    xml.loc sitemap_tags_url
    xml.lastmod Tag.maximum(:updated_at)&.iso8601
  end
end
