# frozen_string_literal: true

class TagsController < ApplicationController
  ORDER = { published_at: :desc, id: :desc }.freeze
  RATIOS = [ 12, 25, 50 ].freeze

  before_action do
    request.session_options[:skip] = true
  end

  before_action :set_tag

  def show
    entries = Entry.published.tagged_with(@tag.name).preload(:entryable).order(ORDER)

    set_page_and_extract_portion_from(entries, per_page: RATIOS)

    @entries = @page.records
    @related_tags = @tag.related_tags(limit: 10)

    fresh_when(@entries)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private
    def set_tag
      @tag = Tag.find_by!(name: params[:name])
    end
end
