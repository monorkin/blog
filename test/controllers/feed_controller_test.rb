# frozen_string_literal: true

require "test_helper"

class FeedControllerTest < ActionDispatch::IntegrationTest
  test "GET show renders Atom feed" do
    get feed_path(format: :atom)

    assert_response :success
    assert_equal "application/xml", response.media_type
  end

  test "GET show includes published entries" do
    entry = entries(:misguided_mark_entry)

    get feed_path(format: :atom)

    assert_response :success
    assert_includes response.body, entry.title
  end

  test "GET show filters by type" do
    get feed_path(format: :atom, types: "article")

    assert_response :success

    talk = entries(:do_you_really_need_websockets_webcamp_2018_entry)
    assert_no_match(/#{Regexp.escape(talk.title)}/, response.body)
  end

  test "GET show filters by tag" do
    get feed_path(format: :atom, tag: "ruby")

    assert_response :success

    tagged_entry = entries(:vanilla_rails_view_components_with_partials_entry)
    assert_includes response.body, tagged_entry.title
  end

  test "GET show does not create a session" do
    get feed_path(format: :atom)

    assert_response :success
    assert_nil session[:session_id]
  end

test "GET style renders XSL stylesheet" do
    get feed_style_path(format: :xsl)

    assert_response :success
  end

  test "GET style does not create a session" do
    get feed_style_path(format: :xsl)

    assert_response :success
    assert_nil session[:session_id]
  end
end
