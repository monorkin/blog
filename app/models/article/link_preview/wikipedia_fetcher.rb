# frozen_string_literal: true

class Article
  class LinkPreview
    class WikipediaFetcher < GenericFetcher

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

        link_preview.title ||= data.dig('titles', 'display')
        link_preview.image_url ||= data.dig('thumbnail', 'source')
        link_preview.description ||= data.dig('extract')
      end
    end
  end
end
