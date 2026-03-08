# frozen_string_literal: true

class Snap < ApplicationRecord
  include Entryable

  content { ActionText::Content.new("") }

  has_one_attached :file

  validates :title, presence: true
  validates :file, presence: true, on: :create

  def cover_image
    file
  end

  private
    def ensure_entry
      build_entry(slug: slug, published: true, published_at: Time.current) unless entry.present?
    end
end
