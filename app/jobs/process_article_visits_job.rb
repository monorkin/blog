# frozen_string_literal: true

class ProcessArticleVisitsJob < ApplicationJob
  queue_as :statistics
  unique :until_executed, on_conflict: ->(_) { nil }

  def perform(statistic)
    statistic.stored_visits.each do |visit|
      apm.span(:process_visit) do
        statistic.process_visit(visit)
      end
    end

    statistic.save!

    apm.span(:clear_stored_visits) do
      statistic.clear_stored_visits!
    end
  end
end
