# frozen_string_literal: true

class Talk < ApplicationRecord
  include ActionView::Helpers::TextHelper
  include Entryable

  has_one_attached :image
  has_one_attached :video

  has_rich_text :description

  validates :title, presence: true
  validates :event, presence: true
  validates :held_at, presence: true

  def to_param
    [
      title.presence&.parameterize,
      event.presence&.parameterize,
      id
    ].compact.join("-").presence
  end

  def cover_image
    description&.body&.attachments&.compact
      &.select { |a| a.respond_to?(:image?) }
      &.find(&:image?)
  end

  def excerpt(length: 300)
    return nil if description.blank?

    truncate(plain_text, length: length, separator: " ")
  end

  def plain_text
    description.body.to_plain_text.gsub(/\[[^\]]*\]/, "")
  end
end
