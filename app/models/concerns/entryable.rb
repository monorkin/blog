# frozen_string_literal: true

module Entryable
  extend ActiveSupport::Concern

  included do
    class_attribute :content_resolver, default: -> { send(:body) }, instance_accessor: false

    has_one :entry, as: :entryable, touch: true, dependent: :destroy, autosave: true

    scope :with_entry, -> { joins(:entry).preload(:entry) }
    scope :published, -> { with_entry.merge(Entry.published) }
    scope :tagged_with, ->(tags) { joins(:entry).merge(Entry.tagged_with(tags)) }

    before_validation :ensure_entry

    delegate :to_param, :published, :published?, :publish_at, :published_at, :tags, to: :entry, allow_nil: true
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

    case value
    when ActionText::Content
      value
    when ActionText::RichText
      value.body || ActionText::Content.new("")
    else
      ActionText::Content.new(value.to_s)
    end
  end

  def slug
    if defined?(super)
      super()
    elsif respond_to?(:title)
      title&.parameterize
    else
      raise NotImplementedError, "Define a slug method or a title method in #{self.class.name}"
    end
  end

  def plain_text_content
    content&.to_plain_text&.gsub(/\[[^\]]*\]/, "") || ""
  end

  def excerpt(length: 300)
    plain_text_content.truncate(length, separator: " ").presence
  end

  def published=(value)
    ensure_entry
    entry.published = value
  end

  def publish_at=(value)
    ensure_entry
    entry.publish_at = value
  end

  def tags=(value)
    ensure_entry
    entry.tags = value
  end

  private
    def ensure_entry
      build_entry(slug: slug, published_at: Time.current) unless entry.present?
    end
end
