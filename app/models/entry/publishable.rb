# frozen_string_literal: true

module Entry::Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where(published: true).where.not(published_at: (Time.current..)) }

    before_save :set_published_at
  end

  def published?
    published && published_at && published_at <= Time.current
  end

  private
    def set_published_at
      self.published_at ||= publish_at || created_at || Time.current
    end
end
