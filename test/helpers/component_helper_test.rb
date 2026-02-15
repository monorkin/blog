# frozen_string_literal: true

require "test_helper"

class ComponentHelperTest < ActionView::TestCase
  test "#component renders a partial from shared directory" do
    # Stub render to verify correct partial path
    partial_path = nil
    self.define_singleton_method(:render) do |path, options = {}, &block|
      partial_path = path
      "rendered"
    end

    component("test_component")

    assert_equal "shared/test_component", partial_path
  end

  test "#component passes options to the partial" do
    passed_options = nil
    self.define_singleton_method(:render) do |path, options = {}, &block|
      passed_options = options
      "rendered"
    end

    component("test_component", title: "Hello")

    assert_equal({ title: "Hello" }, passed_options)
  end
end
