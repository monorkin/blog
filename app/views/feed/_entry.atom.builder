feed.entry(entry, url: polymorphic_url(entry.entryable), published: entry.published_at) do |feed_entry|
  feed_entry.title(entry.title)
  feed_entry.content(Rails.cache.fetch([ entry, :feed, :content ]) { entry.content }, type: "html")
  feed_entry.summary(Rails.cache.fetch([ entry, :feed, :summary ]) { entry.excerpt }, type: "html")

  feed_entry.author do |author|
    author.name("Stanko Krtalic Rusendic")
    author.email("hey@stanko.io")
  end
end
