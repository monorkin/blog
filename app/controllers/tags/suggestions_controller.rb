# frozen_string_literal: true

class Tags::SuggestionsController < ApplicationController
  ensure_authenticated

  def index
    render json: Tag.suggest(query)
  end
end
