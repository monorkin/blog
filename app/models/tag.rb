# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings, class_name: "Tag::Tagging", inverse_of: :tag, dependent: :destroy
  has_many :entries, through: :taggings, source: :taggable, source_type: "Entry"

  normalizes :name, with: -> { it.strip.downcase.gsub(/[^0-9a-z]/, "-").gsub(/-+/, "-").gsub(/^-|-$/, "") }

  validates :name, presence: true, uniqueness: true

  class << self
    def suggest(query, limit: 10)
      normalized_query = normalize_value_for(:name, query.to_s)

      if normalized_query.present?
        where("name LIKE ?", "#{sanitize_sql_like(normalized_query)}%").limit(limit).pluck(:name)
      else
        none
      end
    end
  end

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
