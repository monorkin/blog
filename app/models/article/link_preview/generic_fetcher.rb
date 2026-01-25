# frozen_string_literal: true

class Article
  class LinkPreview
    class GenericFetcher < ApplicationModel
      USER_AGENT = "stanko.io/1.0.0 link_preview_bot/1.0.0"
      REQUEST_TIMEOUT = 3
      MAX_REDIRECT = 10

      attr_accessor :data

      def self.resolves?(_url)
        true
      end

      def self.fetch(url)
        fetcher = new
        fetcher.fetch!(url)

        Metadata.new(
          title: fetcher.data[:title],
          description: fetcher.data[:description],
          image_url: fetcher.data[:image_url]
        )
      end

      def fetch!(url)
        self.data ||= {}
        fetch_from_url!(preprocess_url(url))
        self
      end

      private
        def preprocess_url(url)
          url
        end

        def fetch_from_url!(url, redirect_count = 0)
          return if redirect_count > MAX_REDIRECT
          return if url.blank?

          response = http_client.get(url)
          return if response.is_a?(HTTPX::ErrorResponse)

          if success?(response)
            parse_from_response_body!(response)
          elsif redirect?(response)
            redirect_url = response.headers["location"]
            fetch_from_url!(redirect_url, redirect_count + 1)
          end
        rescue SocketError, OpenSSL::SSL::SSLError, ArgumentError
          nil
        end

        def http_client
          @http_client ||= HTTPX
            .with(timeout: { operation_timeout: REQUEST_TIMEOUT })
            .with(headers: { "user-agent" => USER_AGENT, "accept" => accept_header })
        end

        def accept_header
          "text/html"
        end

        def parse_from_response_body!(response)
          parse_body(StringIO.new(response.body.to_s))
        end

        def parse_body(io)
          Nokogiri::HTML::SAX::Parser
            .new(TagsSaxParser.new(data))
            .parse_io(io)
        end

        def success?(response)
          (200...300).include?(response.status)
        end

        def redirect?(response)
          (300...400).include?(response.status)
        end
    end
  end
end
