# frozen_string_literal: true

module Entryable
  extend ActiveSupport::Concern

  included do
    include Taggable

    has_one :entry, as: :entryable, touch: true, dependent: :destroy
  end

  def published?
    entry&.published?
  end

  def published_at
    entry&.published_at
  end
end
