class SitemapController < ApplicationController
  def index
    sitemap = Sitemap.new

    render xml: sitemap.to_xml
  end
end
