# frozen_string_literal: true

class Search < ApplicationModel
  attr_accessor :term, :result_count

  after_initialize do
    self.result_count ||= 5
  end

  def results
    return [] if term.blank?

    Article
      .published
      .where("title ILIKE ?", "%#{term}%")
      .order(published_at: :desc)
      .limit(result_count)
  end
end
