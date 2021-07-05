# frozen_string_literal: true

class Article
  class Search < ApplicationModel
    TAG_REGEX = /tag:"([^"]+)"/i.freeze

    attr_accessor :term,
                  :scope

    validates :term,
              length: { maximum: 500 }

    def resolve
      return scope if invalid? || unsearchable?

      scope
        .then { |scope| filter_by_term(scope) }
        .then { |scope| filter_by_tags(scope) }
    end

    def unsearchable?
      !searchable?
    end

    def searchable?
      term.present?
    end

    private

    def filter_by_term(scope)
      search_term = term.gsub(TAG_REGEX, '').strip
      return scope if search_term.blank?

      scope.search(search_term)
    end

    def filter_by_tags(scope)
      tags = term.scan(TAG_REGEX).flatten
      return scope if tags.blank?

      # This query is broken into two separate queries to avoid having to deal
      # with pg_search and DISTINCT semantics
      taggings = Article::Tagging.joins(:tag).where(tags: { name: tags })
      scope.where(id: taggings.pluck(:article_id))
    end
  end
end
