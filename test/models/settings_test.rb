# frozen_string_literal: true

require "test_helper"

class SettingsTest < ActiveSupport::TestCase
  test "#color_scheme= accepts valid schemes" do
    settings = Settings.new

    Settings::COLOR_SCHEMES.each do |scheme|
      settings.color_scheme = scheme
      assert_equal scheme, settings.color_scheme
    end
  end

  test "#color_scheme= rejects invalid values" do
    settings = Settings.new
    settings.color_scheme = "neon"

    assert_nil settings.color_scheme
  end

  test "#color_scheme= normalizes case and whitespace" do
    settings = Settings.new

    settings.color_scheme = " Dark "

    assert_equal "dark", settings.color_scheme
  end

  test "#color_scheme_or_default returns the scheme when set" do
    settings = Settings.new
    settings.color_scheme = "dark"

    assert_equal "dark", settings.color_scheme_or_default
  end

  test "#color_scheme_or_default returns auto when unset" do
    settings = Settings.new

    assert_equal "auto", settings.color_scheme_or_default
  end

  test "#color_scheme_auto? returns true when scheme is auto" do
    settings = Settings.new
    settings.color_scheme = "auto"

    assert settings.color_scheme_auto?
    assert_not settings.color_scheme_dark?
    assert_not settings.color_scheme_light?
  end

  test "#color_scheme_dark? returns true when scheme is dark" do
    settings = Settings.new
    settings.color_scheme = "dark"

    assert settings.color_scheme_dark?
    assert_not settings.color_scheme_auto?
  end
end
