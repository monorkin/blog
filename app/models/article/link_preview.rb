# frozen_string_literal: true

require 'async'
require 'async/http/internet'
require 'async/http/body/pipe'

class Article
  class LinkPreview < ApplicationModel
    attr_accessor :url,
                  :image_url,
                  :title,
                  :description,
                  :updated_at

    validates :url,
              presence: true,
              url: { loopback: false }
    validates :title,
              presence: true,
              if: -> { updated_at.present? }

    def fetch!
      return self unless valid?

      fetcher.fetch!(url)
      self
    end

    def fetcher
      @fetcher ||=
        case url
        when /^(.*\.)?wikipedia\.org(\/.*)?$/i
          WikipediaFetcher.new(link_preview: self)
        else
          GenericFetcher.new(link_preview: self)
        end
    end

    def image?
      image_url.present?
    end
  end
end
