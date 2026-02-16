# frozen_string_literal: true

require "test_helper"

class EntryHelperTest < ActionView::TestCase
  test "#entry_list renders a ul with default classes" do
    self.define_singleton_method(:render) do |collection|
      "<li>entry</li>".html_safe
    end

    result = entry_list([ entries(:misguided_mark_entry) ])

    assert_match(/<ul/, result)
    assert_match(/entry-list/, result)
  end

  test "#entry_list accepts custom classes" do
    self.define_singleton_method(:render) do |collection|
      "".html_safe
    end

    result = entry_list([], class: "custom-class")

    assert_match(/custom-class/, result)
  end
end
