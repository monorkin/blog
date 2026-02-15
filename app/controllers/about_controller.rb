# frozen_string_literal: true

class AboutController < ApplicationController
  before_action only: %i[show] do
    request.session_options[:skip] = true
  end

  def show
    @latest_entries = Article.published.order(published_at: :desc, id: :desc).limit(3).map(&:entry)

    fresh_when @latest_entries
  end
end
