# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings,
           class_name: 'Tag::Tagging',
           inverse_of: :tag,
           dependent: :destroy
  has_many :articles,
           through: :taggings,
           source: :taggable,
           source_type: 'Article'

  normalizes :name, with: -> { _1.strip.downcase.gsub(/[^0-9a-z]/, '-').gsub(/-+/, '-').gsub(/^-|-$/, '') }

  validates :name,
            presence: true,
            uniqueness: true

  def to_param
    name
  end

  def published_articles_count
    articles.published.count
  end

  def related_tags(limit: 10)
    Tag
      .joins(:taggings)
      .where(taggings: { taggable_id: articles.published.pluck(:id), taggable_type: 'Article' })
      .where.not(id: id)
      .group(:id)
      .order(Arel.sql('COUNT(taggings.id) DESC'))
      .limit(limit)
  end
end
