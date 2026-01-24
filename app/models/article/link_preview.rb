# frozen_string_literal: true

class Article
  class LinkPreview < ApplicationModel
    FETCHERS = [
      WikipediaFetcher,
      GenericFetcher
    ].freeze

    CACHE_EXPIRY = 30.days

    attr_accessor :id, :url, :updated_at, :image_url, :title, :description

    after_initialize do
      self.id ||= self.class.id_from_url(url.to_s)
      load_from_cache
    end

    validates :url,
              presence: true,
              url: { loopback: false }
    validates :title,
              presence: true,
              if: :fetched?

    class << self
      def for(url:, article:)
        return nil unless article.content.body.links.include?(url)

        new(
          id: id_from_url(url),
          url: url
        )
      end

      def id_from_url(url)
        Base64.urlsafe_encode64(url)
      end
    end

    def cache_key
      [self.class.name.underscore, id || :new].join('/')
    end

    def unfetched?
      !fetched?
    end

    def fetched?
      title.present? || updated_at.present? || image_url.present? || description.present?
    end

    def image?
      image_url.present?
    end

    def fetch!
      return self if invalid?

      fetcher&.fetch!(url)

      if fetcher.data
        self.updated_at = Time.now.utc
        self.title = fetcher.data[:title]
        self.description = fetcher.data[:description]
        self.image_url = fetcher.data[:image_url]
        save_to_cache
      end

      self
    end

    def fetcher
      @fetcher ||= FETCHERS.find { |fetcher| fetcher.resolves?(url) }&.new
    end

    private

    def load_from_cache
      return unless id.present?

      cached_data = Rails.cache.read(cache_key)
      return unless cached_data.is_a?(Hash)

      self.updated_at = cached_data[:updated_at]
      self.image_url = cached_data[:image_url]
      self.title = cached_data[:title]
      self.description = cached_data[:description]
    end

    def save_to_cache
      return unless id.present?

      Rails.cache.write(
        cache_key,
        {
          updated_at: updated_at,
          image_url: image_url,
          title: title,
          description: description
        },
        expires_in: CACHE_EXPIRY
      )
    end
  end
end
