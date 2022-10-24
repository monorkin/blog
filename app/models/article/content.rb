# frozen_string_literal: true

require 'nokogiri'
require 'redcarpet'
require 'redcarpet/render_strip'

class Article
  class Content < ApplicationModel
    RENDERERS = {
      html: {
        class: HtmlRenderer,
        options: {
          link_attributes: { target: '_blank' }
        }
      }.freeze
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
                  :attachments

    def to_html
      @html_content ||= render_to(:html)
    end

    def to_text
      @text_content ||= Nokogiri::HTML(to_html).text.strip
    end

    def to_s
      content
    end

    def render_to(format)
      markdown_renderer_for(format)&.render(content)
    end

    def markdown_renderer_for(format)
      return unless RENDERERS.key?(format)

      format = RENDERERS[format]
      return if format.blank?

      renderer = format[:class]
                 .new(format[:options].reverse_merge(attachments: attachments))

      Redcarpet::Markdown.new(renderer, **MARKDOWN_CONFIG)
    end

    def word_count
      @word_count ||= to_text.split(/\s+/)
                             .select { |word| word.length > 1 }
                             .count
    end

    def reading_time(words_per_minute: AVERAGE_ADULT_WORDS_PER_MINUTE)
      (word_count / words_per_minute).ceil.to_i
    end

    def attachment_urls
      content.scan(MARKDOWN_ATTACHMENT_URLS_REGEX).flatten
    end

    def link_urls
      content.scan(MARKDOWN_LINK_URLS_REGEX).flatten
    end
  end
end
