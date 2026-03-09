# frozen_string_literal: true

class SnapsController < ApplicationController
  ORDER = { publish_at: :desc }.freeze
  RATIOS = [12, 24, 48].freeze

  before_action only: %i[index show] do
    request.session_options[:skip] = true
  end

  before_action :set_snap, only: %i[show edit update destroy]
  ensure_authenticated only: %i[new create edit update destroy]

  def index
    set_page_and_extract_portion_from(snaps, per_page: RATIOS)

    @snaps = @page.records

    fresh_when(@page)
  end

  def show
    @previous_snap = snaps.where(entries: { publish_at: (@snap.entry.publish_at..) }).where.not(id: @snap.id).last
    @next_snap = snaps.where(entries: { publish_at: (...@snap.entry.publish_at) }).where.not(id: @snap.id).first

    fresh_when(@snap)
  end

  def new
    @snap = Snap.new
  end

  def create
    if params[:snaps].present?
      create_batch
    else
      create_single
    end
  end

  def edit
  end

  def update
    if @snap.update(permitted_params)
      redirect_to snaps_path, status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @snap.destroy!

    redirect_to snaps_path, status: :see_other
  end

  private
    def snaps
      Snap
        .joins(:entry).merge(Entry.published)
        .order(ORDER)
        .preload(:entry, file_attachment: :blob)
    end

    def set_snap
      @snap = Entry.snaps.from_slug!(params[:id]).entryable
    end

    def permitted_params
      params.require(:snap).permit(:title, :caption, :file, :tags)
    end

    def create_single
      @snap = Snap.new(permitted_params)

      if @snap.save
        redirect_to snaps_path, status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end

    def create_batch
      ActiveRecord::Base.transaction do
        params[:snaps].each do |snap_attrs|
          snap = Snap.new(
            title: snap_attrs[:title],
            caption: snap_attrs[:caption],
            file: snap_attrs[:file]
          )
          snap.tags = snap_attrs[:tags] if snap_attrs[:tags].present?
          snap.save!
        end
      end

      redirect_to snaps_path, status: :see_other
    rescue ActiveRecord::RecordInvalid
      @snap = Snap.new
      flash.now[:alert] = t(".create_failed")
      render :new, status: :unprocessable_entity
    end
end
