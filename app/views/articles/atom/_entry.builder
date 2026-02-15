feed.entry(article, published: article.published_at) do |entry|
  entry.title(article.title)
  entry.content(Rails.cache.fetch([article.entry, :content]) { article.content }, type: "html")
  entry.summary(Rails.cache.fetch([article.entry, :summary]) { article.excerpt }, type: "html")

  entry.author do |author|
    author.name("Stanko Krtalic Rusendic")
    author.email("hey@stanko.io")
  end
end
