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
          .tap { |doc| add_link_preview_attributes_to_html_document(doc) }
          .tap { |doc| change_video_urls_in_html_document(doc) }
          .tap { |doc| change_image_urls_in_html_document(doc) }
          .to_html
      end

      private

      def add_html_attributes_from_curly_colon_syntax(doc)
        attribute_nodes =
          doc.css('p').select { |node| node.text =~ CURLY_COLON_REGEX }

        attribute_nodes.each do |node|
          element = find_previous_element(node)
          next unless element

          add_attributes_to_node(element,
                                 node.text.scan(CURLY_COLON_REGEX).flatten.first)
          node.remove
        end
      end

      def add_link_preview_attributes_to_html_document(document)
        document.css('a').each do |link|
          link['tabindex'] = 0
          link['data-controller'] = 'link-preview'
          link['data-link-preview-id-value'] = LinkPreview.id_from_url(link['href'])
          link['data-action'] = 'mouseover->link-preview#show  mouseout->link-preview#hide focus->link-preview#show  blur->link-preview#hide'
        end
      end

      def change_video_urls_in_html_document(document)
        video_map = attachments.select(&:video?)
                               .each_with_object({}) { |img, map| map[img.original_path] = img }

        return if video_map.blank?

        document.css('img').each do |img|
          video = video_map[img['src']]
          next if video.blank?

          img.name = 'video'
          img['poster'] = video.attachment_url(:preview)
          img['controls'] = 'controls'
          img['style'] ||= ''
          img['style'] += "--aspect-ratio: #{video.aspect_ratio};"
          img.add_class('video-player')
          if video.attachment_url(:mp4).present? && video.attachment_url(:webm).present?
            img.add_child "<source src='#{video.attachment_url(:mp4)}' type='video/mp4' />"
            img.add_child "<source src='#{video.attachment_url(:webm)}' type='video/webm' />"
          else
            img.add_child "<source src='#{video.attachment_url}' type='#{video.mime_type}' />"
          end
          img.delete('src')
        end
      end

      def change_image_urls_in_html_document(document)
        image_map = attachments.select(&:image?)
                               .each_with_object({}) { |img, map| map[img.original_path] = img }

        document.css('img').each do |img|
          image = image_map[img['src']]
          img['src'] = image&.attachment_url || img['src']
          img['loading'] = :lazy
          img['srcset'] = image&.srcset&.join(', ')
          img['style'] = "--image-aspect-ratio: #{image.aspect_ratio}" if image

          _figure = img.wrap('<figure></figure>').parent

          if img['alt']
            img.add_next_sibling("<figcaption>#{img['alt']}</figcaption>")
          end
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
