# frozen_string_literal: true

atom_feed(root_url: root_url, instruct: { "xml-stylesheet": { href: feed_style_path, type: "text/xsl" } }) do |feed|
  feed.title("Stanko Krtalic Rusendic")
  feed.updated(@entries.maximum(:updated_at)) if @entries.any?

  # I can't cache only on @entries because the query contains the current time which always busts the cache.
  # So I build a cache key manually based on the max updated_at, count and the types and tags filters.
  cache([ :entries, @entries.count, @entries.maximum(:updated_at), types: @types, tags: @tags ]) do
    @entries.each do |entry|
      # Rails allows caching of builders only within the same buffer/view so this can't be a partial
      cache(entry) do
        feed.entry(entry.entryable, url: polymorphic_url(entry.entryable), published: entry.published_at) do |feed_entry|
          feed_entry.title(entry.title)
          feed_entry.content(entry.content, type: "html")
          feed_entry.summary(entry.excerpt, type: "html")

          feed_entry.author do |author|
            author.name("Stanko Krtalic Rusendic")
            author.email("hey@stanko.io")
          end
        end
      end
    end
  end
end
