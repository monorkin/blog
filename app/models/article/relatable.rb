# frozen_string_literal: true

module Article::Relatable
  extend ActiveSupport::Concern

  def related_articles(limit: 5)
    tag_ids = entry.tags.pluck(:id)

    Article
      .published
      .joins(entry: :taggings)
      .preload(:entry)
      .where.not(id: id)
      .where(tag_taggings: { tag_id: tag_ids })
      .group("articles.id")
      .order(Arel.sql("COUNT(tag_taggings.tag_id) DESC"), Arel.sql("entries.published_at DESC"))
      .limit(limit)
  end
end
