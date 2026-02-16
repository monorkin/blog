# frozen_string_literal: true

require "application_system_test_case"

class TalksTest < ApplicationSystemTestCase
  test "the index page lists talks" do
    visit talks_url

    assert_text talks(:do_you_really_need_websockets_webcamp_2018).title
  end

  test "the show page displays a talk" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    visit talks_url

    assert_text talk.title
    find("a[href='#{talk_path(talk)}']").click

    assert_text talk.title
  end

  test "infinite scroll loads more talks" do
    visit talks_url

    # First page should be displayed
    assert_selector "li", minimum: 12

    # Scroll to the bottom to trigger infinite scroll
    scroll_to :bottom
    sleep 1

    # A second page should have loaded via turbo-frame
    assert_selector "turbo-frame", minimum: 1
  end
end
