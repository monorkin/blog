# frozen_string_literal: true

class Sitemap < ApplicationModel
  include Rails.application.routes.url_helpers

  attr_accessor :scope

  after_initialize do
    self.scope ||= Article.published
  end

  def to_xml
    build.finalize!
    adapter.data
  end

  private

  def build
    SitemapGenerator::LinkSet.new(link_set_options).tap do |set|
      configure_defaults!(set)
      add_static_paths!(set)
      add_article_paths!(set)
    end
  end

  def link_set_options
    {
      adapter: adapter,
      compress: false,
      verbose: false,
      include_root: false
    }
  end

  def adapter
    @adapter ||= IoAdapter.new
  end

  def configure_defaults!(set)
    set.default_host = Rails.application.routes.default_url_options[:host]
  end

  def add_static_paths!(set)
    set.add root_path,
            changefreq: 'monthly',
            priority: 1.0,
            lastmod: File.mtime(Rails.root.join('app/views/about/show.html.slim'))
  end

  def add_article_paths!(set)
    scope.find_each do |article|
      set.add article_path(article),
              changefreq: 'monthly',
              priority: 0.75,
              lastmod: article.updated_at
    end
  end
end
