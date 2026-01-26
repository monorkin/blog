# frozen_string_literal: true

module Article::Pageable
  extend ActiveSupport::Concern

  def previous_article
    if entry.published_at
      Article
        .published
        .joins(:entry)
        .preload(:entry)
        .where(entries: { published_at: ...entry.published_at })
        .order("entries.published_at DESC")
        .first
    end
  end

  def next_article
    if entry.published_at
      Article
        .published
        .joins(:entry)
        .preload(:entry)
        .where(entries: { published_at: (entry.published_at + 1.second).. })
        .order("entries.published_at ASC")
        .first
    end
  end
end
