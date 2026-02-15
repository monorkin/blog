# frozen_string_literal: true

require "test_helper"

class ColorSchemeHelperTest < ActionView::TestCase
  test "#current_color_scheme_class returns light class for light scheme" do
    Current.settings = Settings.new(color_scheme: "light")

    assert_equal "color-scheme--light", current_color_scheme_class
  end

  test "#current_color_scheme_class returns dark class for dark scheme" do
    Current.settings = Settings.new(color_scheme: "dark")

    assert_equal "color-scheme--dark", current_color_scheme_class
  end

  test "#current_color_scheme_class returns nil for auto scheme" do
    Current.settings = Settings.new(color_scheme: "auto")

    assert_nil current_color_scheme_class
  end

  test "#color_scheme_class_for returns correct class for each scheme" do
    assert_equal "color-scheme--light", color_scheme_class_for(:light)
    assert_equal "color-scheme--dark", color_scheme_class_for(:dark)
    assert_nil color_scheme_class_for(:auto)
  end

  test "#light_color_scheme_class returns the light class constant" do
    assert_equal "color-scheme--light", light_color_scheme_class
  end

  test "#dark_color_scheme_class returns the dark class constant" do
    assert_equal "color-scheme--dark", dark_color_scheme_class
  end
end
