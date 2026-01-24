# frozen_string_literal: true

require "application_system_test_case"

class TalksTest < ApplicationSystemTestCase
  fixtures :talks, "action_text/rich_texts"

  test "the index page should pass all accessibility criteria with talks present" do
    visit talks_url

    click_link "Older talks"
    assert_accessible(page)

    click_link "Newer talks"
    assert_accessible(page)
  end

  test "the index page should pass all accessibility criteria wihtout talks" do
    Talk.all.destroy_all

    visit talks_url

    assert_accessible(page)
  end

  test "the show page has no accessibility issues" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    visit talks_url

    assert_text talk.title
    find("a[href='#{talk_path(talk)}']").click

    assert_accessible(page)
  end
end
