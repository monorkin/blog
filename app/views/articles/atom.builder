cache @articles do
  atom_feed(root_url: articles_url) do |feed|
    feed.title("Stanko Krtalic Rusendic")
    feed.updated(@articles.maximum(:updated_at)) if @articles.size > 0

    @articles.find_each do |article|
      feed.entry(article, published: article.published_at) do |entry|
        entry.title(article.title)
        entry.content(article.content, type: "html")

        entry.author do |author|
          author.name("Stanko Krtalic Rusendic")
          author.email("hey@stanko.io")
        end
      end
    end
  end
end
