# frozen_string_literal: true

atom_feed(root_url: root_url, instruct: {
            "xml-stylesheet": { href: feed_style_path, type: "text/xsl" }
          }) do |feed|
  feed.title("Stanko Krtalic Rusendic")
  feed.updated(@entries.maximum(:updated_at)) if @entries.any?

  render partial: "feed/entry", collection: @entries, as: :entry, locals: { feed: feed }
end
