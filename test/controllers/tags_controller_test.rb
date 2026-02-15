# frozen_string_literal: true

require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  test "GET show renders tag page with tagged entries" do
    tag = tags(:ruby)
    entry = entries(:vanilla_rails_view_components_with_partials_entry)

    get tag_path(tag)

    assert_response :success
    assert_select "h1", text: "##{tag.name}"

    # Should show the tagged entry
    assert_select "ul li", minimum: 1
    assert_select "li", text: /#{entry.title}/
  end

  test "GET show handles non-existent tag" do
    nonexistent_name = "zzz-truly-nonexistent-tag-zzz-12345"

    # Ensure the tag doesn't exist
    assert_nil Tag.find_by(name: nonexistent_name)

    # Make the request - will attempt to redirect to errors controller
    # In test environment without errors controller, Rails will serve 404
    get tag_path(name: nonexistent_name)

    assert_response :not_found
  end

  test "GET show only shows published entries" do
    tag = tags(:people)

    # Create unpublished article with tag
    article = Article.create!(
      title: "Unpublished Article",
      body: "Content",
      published: false,
      tags: "people"
    )

    get tag_path(tag)

    assert_response :success

    # Should only show published entries
    response_body = response.body
    assert_match(/misguided-mark/, response_body)
    assert_no_match(/Unpublished Article/, response_body)
  end

  test "GET show paginates entries" do
    tag = tags(:ruby)

    # Create enough entries to exceed first page (RATIOS = [12, 25, 50])
    # Need more than 12 to trigger pagination
    15.times do |i|
      Article.create!(
        title: "Article #{i}",
        body: "Content #{i}",
        published: true,
        publish_at: i.days.ago,
        tags: "ruby"
      )
    end

    get tag_path(tag)

    assert_response :success

    # Should have pagination link
    assert_select 'a[href*="page"]', minimum: 1
  end

  test "GET show orders entries by published_at desc" do
    tag = tags(:ruby)

    # Create articles with different published_at times
    Article.create!(
      title: "Older Article",
      body: "Content",
      published: true,
      publish_at: 2.days.ago,
      tags: "ruby"
    )

    Article.create!(
      title: "Newer Article",
      body: "Content",
      published: true,
      publish_at: 1.day.ago,
      tags: "ruby"
    )

    get tag_path(tag)

    assert_response :success

    # Newer entry should appear first in the response
    newer_pos = response.body.index("Newer Article")
    older_pos = response.body.index("Older Article")

    assert newer_pos < older_pos, "Entries should be ordered by published_at desc"
  end

  test "GET show includes canonical tag" do
    tag = tags(:ruby)

    get tag_path(tag)

    assert_response :success
    assert_select 'link[rel="canonical"][href=?]', tag_url(tag)
  end

  test "GET show includes SEO meta tags" do
    tag = tags(:ruby)

    get tag_path(tag)

    assert_response :success

    # Check for basic SEO tags
    assert_select 'meta[name="description"]'
    assert_select 'meta[property="og:title"]'
    assert_select 'meta[property="og:description"]'
    assert_select 'meta[name="twitter:card"]'
  end

  test "GET show responds to turbo_stream format for pagination" do
    tag = tags(:ruby)

    # Create many entries to trigger pagination
    15.times do |i|
      Article.create!(
        title: "Pagination Article #{i}",
        body: "Content #{i}",
        published: true,
        publish_at: i.days.ago,
        tags: "ruby"
      )
    end

    get tag_path(tag, page: 2), as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end
end
