# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings, class_name: "Tag::Tagging", inverse_of: :tag, dependent: :destroy
  has_many :entries, through: :taggings, source: :taggable, source_type: "Entry"

  normalizes :name, with: -> { it.strip.downcase.gsub(/[^0-9a-z]/, "-").gsub(/-+/, "-").gsub(/^-|-$/, "") }

  validates :name, presence: true, uniqueness: true

  def to_param
    name
  end

  def published_entries_count
    entries.published.count
  end

  def related_tags(limit: 10)
    Tag
      .joins(:taggings)
      .where(taggings: { taggable_id: entries.published.pluck(:id), taggable_type: "Entry" })
      .where.not(id: id)
      .group(:id)
      .order(Arel.sql("COUNT(taggings.id) DESC"))
      .limit(limit)
  end
end
