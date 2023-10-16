# frozen_string_literal: true

require 'async'
require 'async/http/internet'
require 'async/http/body/pipe'

class Article
  class LinkPreview
    class GenericFetcher < ApplicationModel
      USER_AGENT = 'stanko.io/1.0.0 link_preview_bot/1.0.0'
      REQUEST_TIMEOUT = 3
      MAX_REDIRECT = 10

      attr_accessor :data

      def self.resolves?(_url)
        true
      end

      def fetch!(url)
        self.data ||= {}

        Sync do |task|
          internet = Async::HTTP::Internet.new
          fetch_from_url!(internet, task, preprocess_url(url))
        ensure
          internet.close
        end

        self
      end

      private

      def preprocess_url(url)
        url
      end

      def fetch_from_url!(internet, task, url)
        redirect_count = 0
        response = nil

        loop do
          return if redirect_count > MAX_REDIRECT
          return if url.blank?

          task.with_timeout(REQUEST_TIMEOUT) do
            response = internet.get(url, headers, nil)
          end

          return parse_from_response_body!(response) if success?(response)

          # An error occured if it's not a redirect, break iteration
          return unless redirect?(response)

          redirect_count += 1
          url = redirect_to(response)
          response.close
        end
      rescue Async::TimeoutError, SocketError, ArgumentError, OpenSSL::SSL::SSLError
        nil
      ensure
        response&.close
      end

      def headers
        @headers ||= build_headers
      end

      def build_headers
        [
          ['User-Agent', USER_AGENT],
          ['Accept', accept_header]
        ]
      end

      def accept_header
        'text/html'
      end

      def parse_from_response_body!(response)
        pipe = Async::HTTP::Body::Pipe.new(response.body)

        parse_body(pipe.to_io)
      ensure
        pipe.close
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

      def redirect_to(response)
        response.headers['location']
      end
    end
  end
end
