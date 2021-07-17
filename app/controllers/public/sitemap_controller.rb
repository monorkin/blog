# frozen_string_literal: true

module Public
  class SitemapController < PublicController
    def index
      sitemap = Sitemap.new

      render xml: sitemap.to_xml
    end
  end
end
