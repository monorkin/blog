# frozen_string_literal: true

require 'nokogiri'
require 'redcarpet'
require 'redcarpet/render_strip'

class Article
  class Content < ApplicationModel
    RENDERERS = {
      html: HtmlRenderer
    }.freeze
    MARKDOWN_CONFIG = {
      no_intra_emphasis: true,
      tables: true,
      fenced_code_blocks: true,
      disable_indented_code_blocks: true,
      strikethrough: true,
      superscript: true,
      underline: true,
      highlight: true,
      footnotes: true
    }.freeze
    AVERAGE_ADULT_WORDS_PER_MINUTE = 200
    MARKDOWN_ATTACHMENT_URLS_REGEX = /!\[[^\]]*\]\((.+)\)/.freeze
    MARKDOWN_LINK_URLS_REGEX = /\[[^\]]*\]\((.+)\)/.freeze

    attr_accessor :content,
                  :article

    def self.markdown_renderer(format)
      return unless RENDERERS.key?(format)

      @markdown_renderer ||= {}
      @markdown_renderer[format] ||= Redcarpet::Markdown.new(
        RENDERERS[format],
        **MARKDOWN_CONFIG
      )
    end

    def to_html(raw: false)
      @html_content ||= {}
      @html_content[raw] ||= Nokogiri::HTML(render_to(:html)).tap do |document|
        next if raw

        add_publication_date_to_html_document(document)
        change_attachemnt_urls_in_html_document(document)
        add_link_preview_attributes_to_html_document(document)
      end.to_s
    end

    def to_text
      @text_content ||= Nokogiri::HTML(to_html(raw: true)).text.strip
    end

    def to_s
      content
    end

    def word_count
      @word_count ||= to_text.split(/\s+/)
                             .select { |word| word.length > 1 }
                             .count
    end

    def reading_time
      (word_count / AVERAGE_ADULT_WORDS_PER_MINUTE).ceil.to_i
    end

    def render_to(format)
      self.class.markdown_renderer(format)&.render(content)
    end

    def attachment_urls
      content.scan(MARKDOWN_ATTACHMENT_URLS_REGEX).flatten
    end

    def link_urls
      content.scan(MARKDOWN_LINK_URLS_REGEX).flatten
    end

    def valid_link?(href, hmac)
      hmac == link_id(href)
    end

    private

    def add_publication_date_to_html_document(document)
      document.css('body').first.add_previous_sibling(
        '<time class="article__publishing_date" '\
              "datetime=\"#{article.published_at.iso8601}\">"\
          "#{article.published_at.strftime('%B %d, %Y')}"\
        '</time>'
      )
    end

    def change_attachemnt_urls_in_html_document(document)
      image_map = article.images.map { |i| [i.original_path, i] }.to_h

      document.css('img').each do |img|
        image = image_map[img['src']]
        img['src'] = image&.image_url || img['src']
        img['loading'] = :lazy
        img['srcset'] = image&.srcset&.join(', ')
        img['style'] = "--image-aspect-ratio: #{image.aspect_ratio}" if image

        _figure = img.wrap('<figure></figure>').parent

        if img['alt']
          img.add_next_sibling("<figcaption>#{img['alt']}</figcaption>")
        end
      end
    end

    def add_link_preview_attributes_to_html_document(document)
      document.css('a').each do |link|
        link['tabindex'] = 0
        link['data-controller'] = 'link-preview'
        link['data-link-preview-id-value'] = link_id(link['href'])
        link['data-action'] = 'mouseover->link-preview#show  mouseout->link-preview#hide focus->link-preview#show  blur->link-preview#hide'
      end
    end

    def link_id(href)
      OpenSSL::HMAC.hexdigest('SHA256', md5_digest, href)
    end

    def md5_digest
      @md5_digest ||= Digest::MD5.hexdigest(content)
    end
  end
end
