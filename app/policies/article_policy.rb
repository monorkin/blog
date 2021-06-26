# frozen_string_literal: true

class ArticlePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if admin?

    record.published?
  end

  class Scope < Scope
    def resolve
      return scope if admin?

      scope.published
    end
  end
end
