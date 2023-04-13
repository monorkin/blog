atom_feed(root_url: articles_url) do |feed|
  feed.title("Stanko's blog")
  feed.description("Stanko K.R.'s personal blog")
  feed.author("Stanko K.R.")
  feed.updated(@articles.maximum(:published_at)) if @articles.size > 0

  @articles.find_each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      # entry.content(article.content, type: "html")
      entry.summary(article.excerpt, type: "html")

      entry.published(article.published_at)

      entry.author do |author|
        author.name("Stanko K.R.")
      end
    end
  end
end
