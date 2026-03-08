# frozen_string_literal: true

class Gallery < ApplicationRecord
  has_many :snaps, -> { order(position: :asc) }, dependent: :destroy

  validates :title, presence: true

  before_validation :set_slug

  def to_param
    slug
  end

  def cover_snaps(limit = 3)
    snaps.joins(:file_attachment).first(limit)
  end

  def multi?
    snaps.size > 1
  end

  def latest_published_at
    snaps.joins(:entry).maximum("entries.published_at")
  end

  private
    def set_slug
      self.slug = title.parameterize if title.present?
    end
end
