# frozen_string_literal: true

module Entryable
  extend ActiveSupport::Concern

  included do
    include Taggable

    class_attribute :content_resolver, default: -> { send(:body) }, instance_accessor: false

    has_one :entry, as: :entryable, touch: true, dependent: :destroy
  end

  class_methods do
    def content(method_name = nil, &block)
      if method_name
        self.content_resolver = -> { send(method_name) }
      elsif block
        self.content_resolver = block
      else
        raise ArgumentError, "Provide either a method name or a block"
      end
    end
  end

  def content
    value = instance_exec(&self.class.content_resolver)

    if value.is_a?(ActionText::Content)
      value
    else
      ActionText::Content.new(value.to_s)
    end
  end

  def excerpt(length: 300)
    plain_text = content&.to_plain_text&.gsub(/\[[^\]]*\]/, "")
    plain_text&.truncate(length, separator: " ").presence
  end

  def published?
    entry&.published?
  end

  def published_at
    entry&.published_at
  end
end
