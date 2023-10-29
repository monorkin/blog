# frozen_string_literal: true

class Talk < ApplicationRecord
  has_one_attached :video

  has_rich_text :description

  validates :title,
    presence: true
  validates :event,
    presence: true
  validates :held_at,
    presence: true

  class << self
    def from_slug!(slug)
      id = slug&.scan(/^(.*-)?(\d+)$/)&.flatten&.last

      find_by!(id: id)
    end
  end

  def to_param
    [
      title.presence&.parameterize,
      event.presence&.parameterize,
      id
    ].join('-').presence
  end
end
