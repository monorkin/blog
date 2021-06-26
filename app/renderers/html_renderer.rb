# frozen_string_literal: true

require 'nokogiri'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

class HtmlRenderer < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet

  CURLY_COLON_REGEX = /^\{:\s*(.+)\s*}$/.freeze

  def initialize(extensions = {})
    super(extensions.merge(link_attributes: { target: '_blank' }))
  end

  def postprocess(full_document)
    Nokogiri
      .HTML(full_document)
      .tap(&method(:add_html_attributes_from_curly_colon_syntax))
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
