# frozen_string_literal: true

class Article
  class Feed < ApplicationModel
    DEFAULT_TITLE = "Stanko's blog"
    DEFAULT_DESCRIPTION = "Stanko K.R.'s personal blog"
    DEFAULT_AUTHOR = 'Stanko K.R.'

    attr_accessor :scope,
                  :host,
                  :title,
                  :description,
                  :author

    after_initialize do
      self.title = DEFAULT_TITLE if title.blank?
      self.description = DEFAULT_DESCRIPTION if description.blank?
      self.author = DEFAULT_AUTHOR if author.blank?
    end

    validates :title,
              presence: true
    validates :description,
              presence: true
    validates :author,
              presence: true
    validates :scope,
              presence: true
    validates :host,
              presence: true

    def to_rss
      rss.to_xml
    end

    def rss
      build_feed('2.0', url_helpers.rss_public_articles_url(host: host))
    end

    def to_atom
      atom.to_xml
    end

    def atom
      build_feed('atom', url_helpers.atom_public_articles_url(host: host))
    end

    private

    def build_feed(type, url)
      RSS::Maker.make(type) do |maker|
        maker.channel.id = host
        maker.channel.title = title
        maker.channel.description = description
        maker.channel.updated = scope.maximum(:published_at).to_time.w3cdtf
        maker.channel.author = author
        maker.channel.link = url

        populate_feed(maker)
      end
    end

    def populate_feed(maker)
      scope.find_each do |article|
        maker.items.new_item do |item|
          item.title = article.title
          item.link = url_helpers.public_article_url(article, host: host)
          item.summary = article.excerpt
          item.updated = article.updated_at.to_time.w3cdtf
        end
      end
    end
  end
end
