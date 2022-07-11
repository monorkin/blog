# frozen_string_literal: true

class Sitemap < ApplicationModel
  include Rails.application.routes.url_helpers

  attr_accessor :scope

  after_initialize do
    self.scope ||= Article.published
  end

  def to_xml
    adapter = IoAdapter.new
    link_set(adapter).finalize!

    adapter.data
  end

  private

  def link_set(adapter)
    SitemapGenerator::LinkSet
      .new(include_root: false, verbose: false, compress: false, adapter: adapter)
      .tap do |set|
        configure_defaults!(set)
        expose_static_paths!(set)
        expose_article_paths!(set)
      end
  end

  def configure_defaults!(set)
    set.default_host = Rails.application.routes.default_url_options[:host]
  end

  def expose_static_paths!(set)
    set.add root_path,
            changefreq: 'monthly',
            priority: 1.0,
            lastmod: File.mtime(Rails.root.join('app/views/about/show.html.slim'))
  end

  def expose_article_paths!(set)
    scope.find_each do |article|
      set.add article_path(article),
              changefreq: 'monthly',
              priority: 0.75,
              lastmod: article.updated_at
    end
  end
end
