# frozen_string_literal: true

atom_feed(root_url: articles_url, instruct: {
            "xml-stylesheet": { href: atom_style_articles_path, type: "text/xsl" }
          }) do |feed|
  feed.title("Stanko Krtalic Rusendic")
  feed.updated(@articles.maximum(:updated_at)) if @articles.size.positive?

  render partial: "articles/atom/entry", collection: @articles, as: :article, locals: { feed: feed }
end
