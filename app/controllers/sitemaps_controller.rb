# frozen_string_literal: true

class SitemapsController < ApplicationController
  before_action do
    request.session_options[:skip] = true
  end

  def index
    fresh_when etag: [ Article.published.maximum(:updated_at), Talk.maximum(:updated_at), Tag.maximum(:updated_at), Snap.published.maximum(:updated_at) ]

    respond_to do |format|
      format.xml
    end
  end

  def pages
    fresh_when etag: [ Article.published.maximum(:updated_at), Talk.maximum(:updated_at), Snap.published.maximum(:updated_at) ]

    respond_to do |format|
      format.xml
    end
  end

  def articles
    @articles = Article.published.order(updated_at: :desc)

    return if fresh_when(@articles)

    respond_to do |format|
      format.xml
    end
  end

  def talks
    @talks = Talk.order(updated_at: :desc)

    return if fresh_when(@talks)

    respond_to do |format|
      format.xml
    end
  end

  def tags
    @tags = Tag.joins(:taggings)
               .where(taggings: { taggable_type: "Entry" })
               .distinct
               .order(:name)

    return if fresh_when(@tags)

    respond_to do |format|
      format.xml
    end
  end

  def snaps
    @snaps = Snap.published.order(updated_at: :desc)

    return if fresh_when(@snaps)

    respond_to do |format|
      format.xml
    end
  end
end
