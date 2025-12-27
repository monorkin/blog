# frozen_string_literal: true

module Taggable
  extend ActiveSupport::Concern

  def self.sanitize_tags(*tags)
    Array.wrap(tags).flatten.map { Tag.normalize_value_for(:name, _1) }.uniq
  end

  included do
    has_many :taggings,
             class_name: 'Tag::Tagging',
             as: :taggable,
             dependent: :destroy
    has_many :tags,
             through: :taggings

    scope :tagged_with, ->(tags) { joins(:tags).where(tags: { name: Taggable.sanitize_tags(tags) }) }
  end

  def tag(*names)
    names = Taggable.sanitize_tags(*names)

    # First we batch-load all existing tags, and
    # assign them skipping any already assigned
    existing_tags = Tag.where(name: names)
    existing_tags.each do |tag|
      next if tags.include?(tag)

      taggings.build(tag: tag)
    end

    # Then we create any new tags that we have encountered
    new_tag_names = names - existing_tags.map(&:name)
    new_tag_names.each do |name|
      tag = Tag.new(name: name)
      taggings.build(tag: tag)
    end
  end

  def tags=(value)
    if value.is_a?(String)
      taggings.clear
      tags.clear
      tag(value.split(','))
    else
      super
    end
  end
end
