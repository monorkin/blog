# frozen_string_literal: true

class TagsController < ApplicationController
  ORDER = { published_at: :desc, id: :desc }.freeze
  RATIOS = [12, 25, 50].freeze

  before_action do
    request.session_options[:skip] = true
  end

  before_action :set_tag

  def show
    articles = Article.published.tagged_with(@tag.name).order(ORDER)
    set_page_and_extract_portion_from(articles, per_page: RATIOS)
    @articles = @page.records
    @related_tags = @tag.related_tags(limit: 10)

    fresh_when(@articles)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def set_tag
    @tag = Tag.find_by!(name: params[:name])
  rescue ActiveRecord::RecordNotFound
    raise if Rails.env.local?

    redirect_to({ controller: :errors, action: :not_found }, status: :see_other)
  end
end
