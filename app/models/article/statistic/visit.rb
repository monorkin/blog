# frozen_string_literal: true

class Article
  class Statistic
    class Visit < ApplicationModel
      FINGERPRINTABLE_HEADERS = %w[
        HTTP_USER_AGENT
        HTTP_ACCEPT
        HTTP_ACCEPT_LANGUAGE
        HTTP_ACCEPT_ENCODING
        HTTP_IF_MODIFIED_SINCE
        HTTP_IF_MATCH
        HTTP_IF_NONE_MATCH
        HTTP_DNT
      ].freeze

      attr_accessor :article,
                    :request,
                    :fingerprint,
                    :referrer_host,
                    :do_not_track

      after_initialize do
        if request.is_a?(self.class)
          build_from_visit!
        else
          build_from_request!
        end

        # Either a request can be given or a fingerprint and a referrer
        # Since the request is bigger than the fingerprint and referrer
        # we discard it to save on memory
        self.request = nil
      end

      def self.storage
        Statistic::Storage.find(config[:provider])
      end

      def self.config
        Rails.application.config.analytics
      end

      def seen?
        storage.remembers?(fingerprint)
      end

      def processed!
        storage.remember!(fingerprint)
      end

      protected

      def storage
        @storage ||= self.class.storage.new(article: article,
                                            expected_size: config[:expected_size],
                                            error_rate: config[:error_rate],
                                            options: config[:provider_config])
      end

      def config
        self.class.config
      end

      private

      def build_from_visit!
        self.fingerprint = request.fingerprint
        self.referrer_host = request.referrer_host
      end

      def build_from_request!
        self.fingerprint ||= generate_fingerpring_for(request)
        self.referrer_host ||= generate_referrer_host_for(request)
      end

      def generate_fingerpring_for(request)
        Digest::MD5.new.tap do |md5|
          md5 << request.remote_ip

          FINGERPRINTABLE_HEADERS.each do |header_name|
            value = request.headers[header_name]
            next if value.blank?

            md5 << value
          end
        end.hexdigest
      end

      def generate_referrer_host_for(request)
        return if request.referrer.blank?
        return unless request.referrer.match?(UrlValidator::URI_REGEX)

        self.referrer_host = URI(request.referrer).host
      rescue ArgumentError
        nil
      end
    end
  end
end
