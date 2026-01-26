# frozen_string_literal: true

module Article::Popular
  extend ActiveSupport::Concern

  class_methods do
    def popular(limit: 5)
      published
        .joins(:entry)
        .preload(:entry)
        .order("entries.published_at DESC")
        .limit(limit)
    end
  end
end
