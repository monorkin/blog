# frozen_string_literal: true

require 'test_helper'

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  fixtures :articles, :talks, :tags, 'tag/taggings', 'action_text/rich_texts'

  test 'GET index renders sitemap index' do
    get sitemap_path

    assert_response :success
    assert_equal 'application/xml', response.media_type

    sitemap = Nokogiri::XML(response.body)

    # Should be a valid sitemap index
    assert_equal 'http://www.sitemaps.org/schemas/sitemap/0.9', sitemap.root.namespace.href
    assert_equal 'sitemapindex', sitemap.root.name

    # Should include all sub-sitemaps
    assert_select 'sitemapindex sitemap loc', text: sitemap_pages_url
    assert_select 'sitemapindex sitemap loc', text: sitemap_articles_url
    assert_select 'sitemapindex sitemap loc', text: sitemap_talks_url
    assert_select 'sitemapindex sitemap loc', text: sitemap_tags_url
  end

  test 'GET pages renders static pages sitemap' do
    get sitemap_pages_path

    assert_response :success
    assert_equal 'application/xml', response.media_type

    sitemap = Nokogiri::XML(response.body)

    # Should be a valid urlset
    assert_equal 'http://www.sitemaps.org/schemas/sitemap/0.9', sitemap.root.namespace.href
    assert_equal 'urlset', sitemap.root.name

    # Should include static pages
    assert_select 'urlset url loc', text: root_url
    assert_select 'urlset url loc', text: articles_url
    assert_select 'urlset url loc', text: talks_url

    # Homepage should have highest priority
    homepage_priority = sitemap.css('url').find { |url| url.css('loc').text == root_url }.css('priority').text.to_f
    assert_equal 1.0, homepage_priority
  end

  test 'GET articles renders articles sitemap' do
    get sitemap_articles_path

    assert_response :success
    assert_equal 'application/xml', response.media_type

    sitemap = Nokogiri::XML(response.body)

    # Should be a valid urlset
    assert_equal 'urlset', sitemap.root.name

    # Should include published articles
    published_count = Article.published.count
    assert_equal published_count, sitemap.css('url').size

    # Should have proper structure
    sitemap.css('url').each do |url_node|
      assert url_node.css('loc').any?, 'Each URL should have a loc'
      assert url_node.css('lastmod').any?, 'Each URL should have a lastmod'
      assert url_node.css('priority').any?, 'Each URL should have a priority'

      # Check lastmod is in ISO8601 format
      lastmod = url_node.css('lastmod').text
      assert_nothing_raised { DateTime.iso8601(lastmod) }
    end
  end

  test 'GET talks renders talks sitemap' do
    get sitemap_talks_path

    assert_response :success
    assert_equal 'application/xml', response.media_type

    sitemap = Nokogiri::XML(response.body)

    # Should be a valid urlset
    assert_equal 'urlset', sitemap.root.name

    # Should include all talks
    talks_count = Talk.count
    assert_equal talks_count, sitemap.css('url').size

    # Should have proper structure
    sitemap.css('url').each do |url_node|
      assert url_node.css('loc').any?, 'Each URL should have a loc'
      assert url_node.css('lastmod').any?, 'Each URL should have a lastmod'
      assert url_node.css('priority').any?, 'Each URL should have a priority'
    end
  end

  test 'GET tags renders tags sitemap' do
    get sitemap_tags_path

    assert_response :success
    assert_equal 'application/xml', response.media_type

    sitemap = Nokogiri::XML(response.body)

    # Should be a valid urlset
    assert_equal 'urlset', sitemap.root.name

    # Should only include tags with articles
    tags_with_articles = Tag.joins(:taggings)
                            .where(taggings: { taggable_type: 'Article' })
                            .distinct
                            .count
    assert_equal tags_with_articles, sitemap.css('url').size

    # Should have proper structure
    sitemap.css('url').each do |url_node|
      assert url_node.css('loc').any?, 'Each URL should have a loc'
      assert url_node.css('lastmod').any?, 'Each URL should have a lastmod'
      assert url_node.css('priority').any?, 'Each URL should have a priority'
    end
  end

  test 'sitemaps use ISO8601 date format' do
    get sitemap_path

    assert_response :success

    sitemap = Nokogiri::XML(response.body)

    sitemap.css('lastmod').each do |lastmod_node|
      lastmod = lastmod_node.text

      # Should be parseable as ISO8601
      assert_nothing_raised do
        DateTime.iso8601(lastmod)
      end

      # Should end with time zone indicator
      assert_match(/Z|[+-]\d{2}:\d{2}$/, lastmod, "#{lastmod} should have timezone")
    end
  end

  test 'sitemap paths have .xml extension' do
    assert_equal '/sitemap.xml', sitemap_path
    assert_equal '/sitemap-pages.xml', sitemap_pages_path
    assert_equal '/sitemap-articles.xml', sitemap_articles_path
    assert_equal '/sitemap-talks.xml', sitemap_talks_path
    assert_equal '/sitemap-tags.xml', sitemap_tags_path
  end

  test 'sitemaps do not create sessions' do
    get sitemap_path

    assert_response :success
    assert_nil session[:session_id]
  end
end
