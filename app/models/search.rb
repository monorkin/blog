# frozen_string_literal: true

class Search < ApplicationModel
  attr_accessor :term, :result_count

  after_initialize do
    self.result_count ||= 5
  end

  def results
    return [] if term.blank?

    {
      articles: articles.load_async,
      talks: talks.load_async,
      tags: tags.load_async
    }
  end

  def articles
    return Article.none if term.blank?

    scope = Article.published.order(published_at: :desc, title: :asc).limit(result_count)

    if term.starts_with?("#")
      scope.tagged_with(term.gsub(/^#/, ""))
    else
      scope.where("title LIKE ? COLLATE NOCASE", "%#{term}%")
    end
  end

  def talks
    return Talk.none if term.blank?

    scope = Talk.published.order(published_at: :desc, title: :asc).limit(result_count)

    if term.starts_with?("#")
      scope.tagged_with(term.gsub(/^#/, ""))
    else
      scope.where("title LIKE ? COLLATE NOCASE", "%#{term}%")
    end
  end

  def tags
    return Tag.none if term.blank? || term.starts_with?("#")

    Tag.normalize_value_for(:name, term)

    Tag
      .where("name LIKE ? COLLATE NOCASE", "%#{term}%")
      .order(name: :asc)
      .limit(result_count)
  end
end
