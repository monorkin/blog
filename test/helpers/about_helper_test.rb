# frozen_string_literal: true

require "test_helper"

class AboutHelperTest < ActionView::TestCase
  test "#about_page_contact_link_content renders title and image" do
    result = about_page_contact_link_content("GitHub", "portrait/small.jpg")

    assert_match(/GitHub/, result)
    assert_match(/<img/, result)
    assert_match(/portrait\/small\.jpg/, result)
  end

  test "#about_page_contact_link_content includes hover transition classes" do
    result = about_page_contact_link_content("GitHub", "portrait/small.jpg")

    assert_match(/group-hover:scale-110/, result)
    assert_match(/transition-all/, result)
  end
end
