# frozen_string_literal: true

class Article
  class LinkPreview
    class WikipediaFetcher < GenericFetcher
      WIKIPEDIA_LINK_REGEX = %r{^(.*\.)?wikipedia\.org(/.*)?$}i

      def self.resolves?(url)
        url&.match?(WIKIPEDIA_LINK_REGEX)
      end

      private

      def preprocess_url(url)
        uri = URI(url)

        article_id = uri.path.gsub(%r{^/wiki/}, '')
        uri.path = "/api/rest_v1/page/summary/#{article_id}"

        uri.to_s
      end

      def accept_header
        'application/json; charset=utf-8; profile="https://www.mediawiki.org/wiki/Specs/Summary/1.2.0"'
      end

      def parse_body(io)
        response = JSON.parse(io.read)

        data[:title] ||= response.dig('titles', 'canonical')
        data[:image_url] ||= response.dig('thumbnail', 'source')
        data[:description] ||= response['extract']
      end
    end
  end
end
