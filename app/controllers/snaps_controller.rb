# frozen_string_literal: true

class SnapsController < ApplicationController
  ORDER = { created_at: :desc }.freeze
  RATIOS = [12, 24, 48].freeze

  before_action only: %i[index show] do
    request.session_options[:skip] = true
  end

  before_action :set_snap, only: %i[show edit update destroy]
  ensure_authenticated only: %i[new create edit update destroy]

  def index
    galleries = Gallery
      .where(id: Snap.joins(:entry).merge(Entry.published).select(:gallery_id))
      .order(ORDER)
      .preload(snaps: [:entry, { file_attachment: :blob }])

    set_page_and_extract_portion_from(galleries, per_page: RATIOS)

    @galleries = @page.records

    fresh_when(@page)
  end

  def show
    siblings = @snap.gallery.snaps.preload(:entry)
    index = siblings.index(@snap)

    @previous_snap = siblings[index - 1] if index && index > 0
    @next_snap = siblings[index + 1] if index

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

  def edit; end

  def update
    if @snap.update(permitted_params.except(:gallery_title))
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
    def set_snap
      @snap = Entry.snaps.from_slug!(params[:id]).entryable
    end

    def permitted_params
      params.require(:snap).permit(:title, :caption, :gallery_title, :file, :tags)
    end

    def create_single
      @snap = Snap.new(permitted_params.except(:gallery_title))
      @snap.gallery = find_or_create_gallery

      if @snap.save
        redirect_to snaps_path, status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end

    def create_batch
      shared_gallery_title = params[:gallery_title].presence

      ActiveRecord::Base.transaction do
        params[:snaps].each do |snap_attrs|
          gallery_title = snap_attrs[:gallery_title].presence || shared_gallery_title || snap_attrs[:title]
          gallery = Gallery.find_or_create_by!(title: gallery_title)

          snap = Snap.new(
            title: snap_attrs[:title],
            caption: snap_attrs[:caption],
            file: snap_attrs[:file],
            gallery: gallery
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

    def find_or_create_gallery
      title = params[:snap][:gallery_title].presence || @snap.title
      Gallery.find_or_create_by!(title: title)
    end
end
