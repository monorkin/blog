# frozen_string_literal: true

class Article
  class LinkPreview < ApplicationModel
    FETCHERS = [
      WikipediaFetcher,
      GenericFetcher
    ].freeze

    attr_accessor :id, :url

    kredis_datetime :updated_at, expires_in: 30.days
    kredis_string :image_url, expires_in: 30.days
    kredis_string :title, expires_in: 30.days
    kredis_string :description, expires_in: 30.days

    # Makes kredis methods behave like normal AR/AM attr accessors
    %i[updated_at image_url title description].each do |name|
      alias_method("kredis_#{name}", name)

      define_method(name) do
        public_send("kredis_#{name}").value
      end

      define_method("#{name}=") do |new_value|
        public_send("kredis_#{name}").value = new_value
      end
    end

    after_initialize do
      self.id ||= self.class.id_from_url(url&.to_s || '')
    end

    validates :url,
              presence: true,
              url: { loopback: false }
    validates :title,
              presence: true,
              if: :fetched?

    class << self
      def for(url:, article:)
        return nil if !article.content.body.links.include?(url)

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
      end

      self
    end

    def fetcher
      @fetcher ||= FETCHERS.find { |fetcher| fetcher.resolves?(url) }&.new
    end
  end
end
