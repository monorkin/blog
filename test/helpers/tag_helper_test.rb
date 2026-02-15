# frozen_string_literal: true

require "test_helper"

class TagHelperTest < ActionView::TestCase
  test "#tag_bubble renders a link to the tag page" do
    tag = tags(:ruby)

    result = tag_bubble(tag)

    assert_match(/<a/, result)
    assert_match(/href="#{Regexp.escape(tag_path(tag))}"/, result)
    assert_match(/#ruby/, result)
  end

  test "#tag_bubble includes styling classes" do
    tag = tags(:ruby)

    result = tag_bubble(tag)

    assert_match(/rounded-full/, result)
    assert_match(/bg-indigo-100/, result)
  end

  test "#tag_bubble accepts additional classes" do
    tag = tags(:ruby)

    result = tag_bubble(tag, class: "ml-2")

    assert_match(/ml-2/, result)
  end
end
