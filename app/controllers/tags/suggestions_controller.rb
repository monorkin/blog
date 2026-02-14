# frozen_string_literal: true

class Tags::SuggestionsController < ApplicationController
  ensure_authenticated

  def index
    query = Tag.normalize_value_for(:name, params[:query].to_s)

    tags = if query.present?
      Tag.where("name LIKE ?", "#{Tag.sanitize_sql_like(query)}%").limit(10).pluck(:name)
    else
      []
    end

    render json: tags
  end
end
