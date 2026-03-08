# frozen_string_literal: true

class FeedController < ApplicationController
  before_action do
    request.session_options[:skip] = true
  end

  def show
    request.format = :atom

    @types = params[:types]&.split(",")&.intersection(Entry.entryable_types.map(&:underscore)).presence
    @tags = Tag.where(name: params[:tag]&.split(",")).pluck(:name).presence

    @entries = Entry.published.preload(:entryable).order(published_at: :desc)
    @entries = @entries.with_types(@types) if @types
    @entries = @entries.tagged_with(@tags) if @tags

    return if fresh_when(@entries)

    render content_type: "application/xml"
  end

  def style
    request.format = :xsl

    @tags = Tag.order(:name)
    @types = Entry.distinct.pluck(:entryable_type).map(&:underscore)

    fresh_when etag: [@tags, @types]
  end
end
