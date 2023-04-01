# frozen_string_literal: true

require 'nokogiri'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

class Article
  class Content
    class HtmlRenderer < Redcarpet::Render::HTML
      include Rouge::Plugins::Redcarpet

      CURLY_COLON_REGEX = /^\{:\s*(.+)\s*}$/.freeze

      attr_accessor :attachments

      def initialize(extensions = {})
        self.attachments = extensions.delete(:attachments)
        super(extensions)
      end

      def postprocess(full_document)
        Nokogiri
          .HTML(full_document)
          .tap { |doc| add_html_attributes_from_curly_colon_syntax(doc) }
          .tap { |doc| change_video_urls_in_html_document(doc) }
          .tap { |doc| change_image_urls_in_html_document(doc) }
          .to_html
      end

      private

      def add_html_attributes_from_curly_colon_syntax(doc)
        attribute_nodes = doc.css('p')
                             .select { |node| node.text =~ CURLY_COLON_REGEX }
                             .flat_map { |node| node.children.count > 1 ? node.children.select { |node| node.text =~ CURLY_COLON_REGEX } : node }
                             .select { |node| node.text =~ CURLY_COLON_REGEX }

        attribute_nodes.each do |node|
          # element = find_previous_element(node)
          # next unless element

          # add_attributes_to_node(element,
          #                        node.text.scan(CURLY_COLON_REGEX).flatten.first)
          node.remove
        end
      end

      def change_video_urls_in_html_document(document)
        video_map = attachments.select(&:video?)
                               .each_with_object({}) { |file, map| map[file.original_path] = file }

        return if video_map.blank?

        document.css('img').each do |img|
          video = video_map[img['src']]
          next if video.blank?

          img.name = 'action-text-attachment'
          img['legacy-attachment-id'] = video.id
        end
      end

      def change_image_urls_in_html_document(document)
        image_map = attachments.select(&:image?)
                               .each_with_object({}) { |file, map| map[file.original_path] = file }

        document.css('img').each do |img|
          image = image_map[img['src']]
          next if image.blank?

          img.name = 'action-text-attachment'
          img['legacy-attachment-id'] = image.id
        end
      end

      def find_previous_element(node)
        loop do
          node = node.previous

          case node
          when Nokogiri::XML::Element then return node
          when nil then return
          end
        end
      end

      def add_attributes_to_node(node, attributes)
        attributes =
          Nokogiri::HTML("<div #{attributes}></div>").css('div').first.attributes

        attributes.each do |key, value|
          node[key] = value.value
        end
      end
    end
  end
end
