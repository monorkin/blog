# frozen_string_literal: true

require 'async'
require 'async/http/internet'
require 'async/http/body/pipe'

class Article
  class LinkPreview < ApplicationModel
    USER_AGENT = 'stanko.io/1.0.0 link_preview_bot/1.0.0'
    REQUEST_TIMEOUT = 3
    MAX_REDIRECT = 10

    attr_accessor :url,
                  :image_url,
                  :title,
                  :description,
                  :updated_at

    after_initialize :fetch!

    validates :url,
              presence: true,
              url: { loopback: false }
    validates :title,
              presence: true,
              if: -> { updated_at.present? }

    def fetch!
      return unless valid?

      Async do |task|
        internet = Async::HTTP::Internet.new
        fetch_from_url!(internet, task)
      ensure
        internet.close
      end

      self.updated_at = Time.current

      self
    end

    def image?
      image_url.present?
    end

    private

    def fetch_from_url!(internet, task, goto_url = url, redirect_count = 0)
      response = nil

      return if redirect_count > MAX_REDIRECT
      return if goto_url.blank?

      headers = [['User-Agent', USER_AGENT], ['Accept', 'text/html']]
      task.with_timeout(REQUEST_TIMEOUT) do
        response = internet.get(goto_url, headers, nil)
      end

      return parse_from_response_body!(response) if success?(response)

      if redirect?(response)
        fetch_from_url!(internet, task, redirect_to(response), redirect_count + 1)
      end
    rescue Async::TimeoutError
      nil
    ensure
      response&.close
    end

    def parse_from_response_body!(response)
      pipe = Async::HTTP::Body::Pipe.new(response.body)

      Nokogiri::HTML::SAX::Parser
        .new(TagsSaxParser.new(self))
        .parse_io(pipe.to_io)
    ensure
      pipe.close
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
