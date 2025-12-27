# frozen_string_literal: true

class SearchController < ApplicationController
  before_action do
    request.session_options[:skip] = true
  end

  def index
    @search = Search.new(permitted_params)
  end

  private

  def permitted_params
    params.fetch(:search, {}).permit(:term)
  end
end
