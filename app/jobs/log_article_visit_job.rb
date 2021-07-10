# frozen_string_literal: true

class LogArticleVisitJob < ApplicationJob
  queue_as :visits

  def perform(article, visit_data)
    visit = Article::Statistic::Visit.new(visit_data)
    return if visit.seen?

    article.statistic.store_visit!(visit)
    ProcessArticleVisitsJob.perform_later(article.statistic)
    visit.remember!
  end
end
