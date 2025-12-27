# frozen_string_literal: true

cache ["feed/#{params[:tag] || 'everything'}", @articles.maximum(:updated_at)] do
  atom_feed(root_url: root_url, instruct: {
              "xml-stylesheet": { href: atom_style_articles_path, type: 'text/xsl' }
            }) do |feed|
    feed.title('Stanko Krtalic Rusendic')
    feed.updated(@articles.maximum(:updated_at)) if @articles.size.positive?

    @articles.find_each do |article|
      feed.entry(article, published: article.published_at) do |entry|
        entry.title(article.title)
        entry.content(article.content, type: 'html')
        entry.summary(article.excerpt, type: 'html')

        entry.author do |author|
          author.name('Stanko Krtalic Rusendic')
          author.email('hey@stanko.io')
        end
      end
    end
  end
end
