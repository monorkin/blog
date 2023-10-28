# frozen_string_literal: true

module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings,
      class_name: "Tag::Tagging",
      as: :taggable,
      dependent: :destroy
    has_many :tags,
      through: :taggings

    scope :including_tags, -> { includes(:tags) }
    scope :tagged_with, ->(tags) { joins(:tags).where(tags: { name: tags }) }
  end

  def tag(*names)
    names = Array.wrap(names).map { _1.strip.downcase }.uniq

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
end
