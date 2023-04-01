# frozen_string_literal: true

class AboutController < ApplicationController
  def show
    request.session_options[:skip] = true
    template = 'about/show.html.slim'
    file_last_modified = File.mtime(Rails.root.join("app/views/#{template}"))

    fresh_when last_modified: file_last_modified
  end
end
