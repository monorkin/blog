# frozen_string_literal: true

class SitemapsController < ApplicationController
  before_action do
    request.session_options[:skip] = true
  end

  def index
    respond_to do |format|
      format.xml
    end
  end

  def pages
    respond_to do |format|
      format.xml
    end
  end

  def articles
    @articles = Article.published.order(updated_at: :desc)

    respond_to do |format|
      format.xml
    end
  end

  def talks
    @talks = Talk.order(updated_at: :desc)

    respond_to do |format|
      format.xml
    end
  end

  def tags
    @tags = Tag.joins(:taggings)
               .where(taggings: { taggable_type: 'Article' })
               .distinct
               .order(:name)

    respond_to do |format|
      format.xml
    end
  end
end
