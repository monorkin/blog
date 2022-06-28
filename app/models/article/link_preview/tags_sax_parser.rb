# frozen_string_literal: true

require 'nokogiri'

class Article
  class LinkPreview
    class TagsSaxParser < Nokogiri::XML::SAX::Document
      OPEN_GRAPH_META_PROPERTY_REGEX = /^og:(.+)$/i.freeze
      TWITTER_META_NAME_REGEX = /^twitter:(.+)$/i.freeze

      attr_accessor :link_preview

      def initialize(link_preview)
        self.link_preview = link_preview
        super()
      end

      def start_element(name, attrs = [])
        case name
        when 'meta' then parse_meta_tag(attrs&.to_h)
        when 'title' then start_title_parsing!
        end
      end

      def end_element(name)
        case name
        when 'title' then stop_title_parsing!
        end
      end

      def characters(string)
        title.write(string) if title.present?
      end

      protected

      attr_accessor :title

      private

      def start_title_parsing!
        self.title = StringIO.new
      end

      def stop_title_parsing!
        title.rewind
        link_preview.title ||= title.read
        self.title = nil
      end

      def parse_meta_tag(attrs)
        if attrs['property']&.match?(OPEN_GRAPH_META_PROPERTY_REGEX)
          parse_open_graph_meta_tag(attrs)
        elsif attrs['name']&.match?(TWITTER_META_NAME_REGEX)
          parse_twitter_meta_tag(attrs)
        end
      end

      def parse_open_graph_meta_tag(attrs)
        case attrs['property'].scan(OPEN_GRAPH_META_PROPERTY_REGEX).flatten.first
        when 'title' then parse_open_graph_title_tag(attrs)
        when 'description' then parse_open_graph_description_tag(attrs)
        when 'image' then parse_open_graph_image_tag(attrs)
        end
      end

      def parse_open_graph_title_tag(attrs)
        return if attrs['content'].blank?

        link_preview.title = attrs['content']
      end

      def parse_open_graph_description_tag(attrs)
        return if attrs['content'].blank?

        link_preview.description = attrs['content']
      end

      def parse_open_graph_image_tag(attrs)
        return if attrs['content'].blank?

        link_preview.image_url = attrs['content']
      end

      def parse_twitter_meta_tag(attrs)
        case attrs['name'].scan(TWITTER_META_NAME_REGEX).flatten.first
        when 'title' then parse_twitter_title_tag(attrs)
        when 'description' then parse_twitter_description_tag(attrs)
        when 'image' then parse_twitter_image_tag(attrs)
        end
      end

      def parse_twitter_title_tag(attrs)
        return if attrs['content'].blank?

        link_preview.title ||= attrs['content']
      end

      def parse_twitter_description_tag(attrs)
        return if attrs['content'].blank?

        link_preview.description ||= attrs['content']
      end

      def parse_twitter_image_tag(attrs)
        return if attrs['content'].blank?

        link_preview.image_url ||= attrs['content']
      end
    end
  end
end
