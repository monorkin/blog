# frozen_string_literal: true

require "test_helper"

class AttachmentsHelperTest < ActionView::TestCase
  test "#resized_image_size scales images down to the limit" do
    assert_equal [ 1024, 1365 ], resized_image_size(1200, 1600, [ 1024, nil ]), "Should limit only the width when there is no height limit"
    assert_equal [ 450, 600 ], resized_image_size(1200, 1600, [ 800, 600 ]), "Should scale by the tighter of the two limits"
    assert_equal [ 800, 234 ], resized_image_size(1024, 300, [ 800, 600 ])
  end

  test "#resized_image_size leaves images within the limit alone" do
    assert_equal [ 327, 335 ], resized_image_size(327, 335, [ 1024, nil ])
    assert_equal [ 0, 0 ], resized_image_size(0, 0, [ 1024, nil ]), "Should pass unknown dimensions through"
  end

  test "#attachment_image_tag sets the image's dimensions" do
    image = Nokogiri::HTML5.fragment(attachment_image_tag("photo.jpg", alt: "A photo", size: [ 1024, 768 ])).at_css("img")

    assert_equal "1024", image["width"]
    assert_equal "768", image["height"]
    assert_equal "A photo", image["alt"]
    assert_equal "lazy", image["loading"]
    assert_equal "attachment__image", image["class"]
    assert_equal "image", image["data-controller"]
  end

  test "#attachment_image_tag leaves out unknown dimensions" do
    image = Nokogiri::HTML5.fragment(attachment_image_tag("photo.jpg", alt: "A photo", size: [ 0, 0 ])).at_css("img")

    assert_nil image["width"]
    assert_nil image["height"]
  end
end
