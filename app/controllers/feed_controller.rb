# frozen_string_literal: true

class FeedController < ApplicationController
  before_action do
    request.session_options[:skip] = true
  end

  def show
    request.format = :atom

    @entries = Entry.published.preload(:entryable).order(published_at: :desc)
    @entries = @entries.with_types(params[:types].split(",")) if params[:types].present?
    @entries = @entries.tagged_with(params[:tag].split(",")) if params[:tag].present?

    fresh_when(@entries)

    render content_type: "application/xml"
  end

  def style
    request.format = :xsl

    @tags = Tag.order(:name)
    @types = Entry.distinct.pluck(:entryable_type).map(&:underscore)

    fresh_when etag: [@tags, @types]
  end
end
