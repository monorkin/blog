# frozen_string_literal: true

class ProcessArticleVisitsJob < ApplicationJob
  queue_as :statistics
  unique :until_executed, on_conflict: ->(_) { nil }

  def perform(statistic)
    statistic.stored_visits.each do |visit|
      statistic.process_visit(visit)
    end

    statistic.save!

    statistic.clear_stored_visits!
  end
end
