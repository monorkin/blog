# frozen_string_literal: true

module Public
  class AboutController < PublicController
    display_header false
    display_footer false

    def show
      template = 'public/about/show.html.slim'
      file_last_modified = File.mtime(Rails.root.join("app/views/#{template}"))

      fresh_when last_modified: file_last_modified, template: template
    end
  end
end
