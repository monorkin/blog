# frozen_string_literal: true

class Snaps::GalleriesController < ApplicationController
  before_action do
    request.session_options[:skip] = true
  end

  def show
    @gallery = Gallery.find_by!(slug: params[:slug])
    @snaps = @gallery.snaps.preload(:entry, file_attachment: :blob)

    fresh_when(@snaps)
  end
end
