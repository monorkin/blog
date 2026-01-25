# frozen_string_literal: true

class Entry < ApplicationRecord
  include Publishable, Sluggable, Taggable

  delegated_type :entryable, types: %w[Article Talk], dependent: :destroy

  scope :with_types, ->(types) { where(entryable_type: types.map { it.to_s.classify }) }
  scope :by_recency, -> { order(published_at: :desc) }

  delegate :title, :content, :excerpt, :cover_image, to: :entryable

  def seo
    @seo ||= SEO.new(self)
  end
end
