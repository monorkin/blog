# frozen_string_literal: true

class Article
  class LinkPreview
    class WikipediaFetcher < GenericFetcher
      WIKIPEDIA_LINK_REGEX = /^(.*\.)?wikipedia\.org(\/.*)?$/i.freeze

      def self.resolves?(url)
        url&.match?(WIKIPEDIA_LINK_REGEX)
      end

      private

      def preprocess_url(url)
        uri = URI(url)

        article_id = uri.path.gsub(/^\/wiki\//, '')
        uri.path = "/api/rest_v1/page/summary/#{article_id}"

        uri.to_s
      end

      def accept_header
        'application/json; charset=utf-8; profile="https://www.mediawiki.org/wiki/Specs/Summary/1.2.0"'
      end

      def parse_body(io)
        data = JSON.parse(io.read)

        link_preview.title ||= data.dig('titles', 'canonical')
        link_preview.image_url ||= data.dig('thumbnail', 'source')
        link_preview.description ||= data['extract']
        link_preview.updated_at = Time.current
      end
    end
  end
end
