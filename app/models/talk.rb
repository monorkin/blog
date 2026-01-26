# frozen_string_literal: true

class Talk < ApplicationRecord
  include Entryable

  content :description

  has_one_attached :cover_image
  has_one_attached :video

  has_rich_text :description

  validates :title, presence: true
  validates :event, presence: true
  validates :held_at, presence: true
end
