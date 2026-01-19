# frozen_string_literal: true

require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  fixtures :articles, :tags, 'tag/taggings', 'action_text/rich_texts'

  test 'GET show renders tag page with tagged articles' do
    tag = tags(:ruby)
    article = articles(:vanilla_rails_view_components_with_partials)

    get tag_path(tag)

    assert_response :success
    assert_select 'h1', text: "##{tag.name}"

    # Should show the tagged article
    assert_select 'ul li', minimum: 1
    assert_select 'li', text: /#{article.title}/
  end

  test 'GET show handles non-existent tag' do
    nonexistent_name = 'zzz-truly-nonexistent-tag-zzz-12345'

    # Ensure the tag doesn't exist
    assert_nil Tag.find_by(name: nonexistent_name)

    # Make the request - will attempt to redirect to errors controller
    # In test environment without errors controller, Rails will serve 404
    get tag_path(name: nonexistent_name)

    assert_response :not_found
  end

  test 'GET show only shows published articles' do
    tag = tags(:people)

    # Create unpublished article with tag
    Article.create!(
      title: 'Unpublished Article',
      content: ActionText::Content.new('Content'),
      published: false,
      tags: 'people'
    )

    get tag_path(tag)

    assert_response :success

    # Should only show published articles
    response_body = response.body
    assert_match(/misguided-mark/, response_body)
    assert_no_match(/Unpublished Article/, response_body)
  end

  test 'GET show paginates articles' do
    tag = tags(:ruby)

    # Create enough articles to exceed first page (RATIOS = [12, 25, 50])
    # Need more than 12 to trigger pagination
    15.times do |i|
      Article.create!(
        title: "Article #{i}",
        content: ActionText::Content.new("Content #{i}"),
        published: true,
        tags: 'ruby',
        publish_at: i.days.ago
      )
    end

    get tag_path(tag)

    assert_response :success

    # Should have pagination link
    assert_select 'a[href*="page"]', minimum: 1
  end

  test 'GET show orders articles by published_at desc' do
    tag = tags(:ruby)

    # Create articles with different published_at times
    Article.create!(
      title: 'Older Article',
      content: ActionText::Content.new('Content'),
      published: true,
      tags: 'ruby',
      publish_at: 2.days.ago
    )

    Article.create!(
      title: 'Newer Article',
      content: ActionText::Content.new('Content'),
      published: true,
      tags: 'ruby',
      publish_at: 1.day.ago
    )

    get tag_path(tag)

    assert_response :success

    # Newer article should appear first in the response
    newer_pos = response.body.index('Newer Article')
    older_pos = response.body.index('Older Article')

    assert newer_pos < older_pos, 'Articles should be ordered by published_at desc'
  end

  test 'GET show includes canonical tag' do
    tag = tags(:ruby)

    get tag_path(tag)

    assert_response :success
    assert_select 'link[rel="canonical"][href=?]', tag_url(tag)
  end

  test 'GET show includes SEO meta tags' do
    tag = tags(:ruby)

    get tag_path(tag)

    assert_response :success

    # Check for basic SEO tags
    assert_select 'meta[name="description"]'
    assert_select 'meta[property="og:title"]'
    assert_select 'meta[property="og:description"]'
    assert_select 'meta[name="twitter:card"]'
  end

  test 'GET show responds to turbo_stream format for pagination' do
    tag = tags(:ruby)

    # Create many articles to trigger pagination
    15.times do |i|
      Article.create!(
        title: "Pagination Article #{i}",
        content: ActionText::Content.new("Content #{i}"),
        published: true,
        tags: 'ruby',
        publish_at: i.days.ago
      )
    end

    get tag_path(tag, page: 2), as: :turbo_stream

    assert_response :success
    assert_equal 'text/vnd.turbo-stream.html', response.media_type
  end
end
