# frozen_string_literal: true

class Article
  class LinkPreview < ApplicationModel
    FETCHERS = [
      WikipediaFetcher,
      GenericFetcher
    ].freeze

    attr_accessor :id,
                  :url,
                  :image_url,
                  :title,
                  :description,
                  :fetched

    kredis_datetime :updated_at

    after_initialize do
      self.id ||= self.class.id_from_url(url&.to_s || '')
    end

    validates :url,
              presence: true,
              url: { loopback: false }
    validates :title,
              presence: true,
              if: :fetched?

    def self.id_from_url(url)
      OpenSSL::HMAC.hexdigest('SHA256',
                              Rails.application.credentials.link_preview.secret,
                              url)
    end

    def self.id_matches_url?(id:, url:)
      ActiveSupport::SecurityUtils.secure_compare(id, id_from_url(url))
    end

    def cache_key
      [self.class.name.underscore, id || :new].join('/')
    end

    def unfetched?
      !fetched?
    end

    def fetched?
      !!fetched
    end

    def image?
      image_url.present?
    end

    def image_url
      fetch! if unfetched?
      @image_url
    end

    def title
      fetch! if unfetched?
      @title
    end

    def description
      fetch! if unfetched?
      @description
    end

    alias _update_at updated_at

    def updated_at
      fetch! if unfetched?
      _update_at.value
    end

    def updated_at=(value)
      Kredis.datetime(kredis_key_for_attribute(:updated_at)).value = value
    end

    def fetch!
      return self if invalid?

      fetcher.fetch!(url)
      self.fetched = true
      self
    end

    def fetcher
      @fetcher ||= FETCHERS
                   .find { |fetcher| fetcher.resolves?(url) }
                   &.new(link_preview: self)
    end
  end
end
