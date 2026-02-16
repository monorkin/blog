# frozen_string_literal: true

require "test_helper"

class AboutHelperTest < ActionView::TestCase
  test "#about_page_contact_link_content renders title and image" do
    result = about_page_contact_link_content("GitHub", "portrait/small.jpg")

    assert_match(/GitHub/, result)
    assert_match(/<img/, result)
    assert_match(/portrait\/small\.jpg/, result)
  end

  test "#about_page_contact_link_content includes BEM component classes" do
    result = about_page_contact_link_content("GitHub", "portrait/small.jpg")

    assert_match(/about__contact/, result)
    assert_match(/about__contact-glow/, result)
  end
end
