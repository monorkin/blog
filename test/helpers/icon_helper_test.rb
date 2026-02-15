# frozen_string_literal: true

require "test_helper"

class IconHelperTest < ActionView::TestCase
  test "#icon_svg renders an SVG element" do
    result = icon_svg('<path d="M0 0" />')

    assert_match(/<svg/, result)
    assert_match(/<path/, result)
  end

  test "#icon_svg accepts custom class" do
    result = icon_svg('<path d="M0 0" />', class: "w-6 h-6")

    assert_match(/w-6 h-6/, result)
  end

  test "#icon_svg accepts custom alt and aria-label" do
    result = icon_svg('<path d="M0 0" />', alt: "Test icon")

    assert_match(/alt="Test icon"/, result)
    assert_match(/aria-label="Test icon"/, result)
  end

  test "#search_icon renders search SVG" do
    result = search_icon

    assert_match(/<svg/, result)
    assert_match(/Search icon/, result)
  end

  test "#close_icon renders close SVG" do
    result = close_icon

    assert_match(/<svg/, result)
    assert_match(/Close icon/, result)
  end

  test "#menu_icon renders menu SVG" do
    result = menu_icon

    assert_match(/<svg/, result)
    assert_match(/Menu icon/, result)
  end

  test "#rss_icon renders RSS SVG" do
    result = rss_icon

    assert_match(/<svg/, result)
    assert_match(/RSS icon/, result)
  end

  test "#sun_icon renders sun SVG" do
    result = sun_icon

    assert_match(/<svg/, result)
    assert_match(/Sun icon/, result)
  end

  test "#moon_icon renders moon SVG" do
    result = moon_icon

    assert_match(/<svg/, result)
    assert_match(/Moon icon/, result)
  end

  test "#settings_icon renders settings SVG" do
    result = settings_icon

    assert_match(/<svg/, result)
    assert_match(/Settings icon/, result)
  end

  test "#computer_icon renders computer SVG" do
    result = computer_icon

    assert_match(/<svg/, result)
    assert_match(/Computer icon/, result)
  end

  test "#arrow_long_right_icon renders arrow right SVG" do
    result = arrow_long_right_icon

    assert_match(/<svg/, result)
    assert_match(/Arrow long right/, result)
  end

  test "#arrow_long_left_icon renders arrow left SVG" do
    result = arrow_long_left_icon

    assert_match(/<svg/, result)
    assert_match(/Arrow long left/, result)
  end

  test "#text_with_icon renders icon before text by default" do
    result = text_with_icon(:search, "Find")

    assert_match(/<svg/, result)
    assert_match(/Find/, result)

    icon_pos = result.index("<svg")
    text_pos = result.index("Find")
    assert icon_pos < text_pos, "Icon should appear before text by default"
  end

  test "#text_with_icon renders icon after text when position is :after" do
    result = text_with_icon(:search, "Find", position: :after)

    icon_pos = result.index("<svg")
    text_pos = result.index("Find")
    assert text_pos < icon_pos, "Text should appear before icon when position is :after"
  end

  test "#text_with_icon raises for unknown icon" do
    assert_raises(ArgumentError) do
      text_with_icon(:nonexistent, "Text")
    end
  end
end
