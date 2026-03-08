# frozen_string_literal: true

class SnapsController < ApplicationController
  before_action only: %i[index show] do
    request.session_options[:skip] = true
  end

  before_action :set_snap, only: %i[show edit update destroy]
  ensure_authenticated only: %i[new create edit update destroy]

  def index
    gallery_ids = Gallery.joins(snaps: :entry)
      .merge(Entry.published)
      .group("galleries.id")
      .order(Arel.sql("MAX(entries.published_at) DESC"))
      .pluck("galleries.id")

    @galleries = Gallery.where(id: gallery_ids)
      .preload(snaps: [:entry, { file_attachment: :blob }])
      .index_by(&:id)
      .values_at(*gallery_ids)

    fresh_when(@galleries)
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
    @snap = Snap.new(permitted_params.except(:gallery_title))
    @snap.gallery = find_or_create_gallery

    if @snap.save
      redirect_to snaps_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
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

    def find_or_create_gallery
      title = params[:snap][:gallery_title].presence || @snap.title
      Gallery.find_or_create_by!(title: title)
    end
end
