# frozen_string_literal: true

require "test_helper"

class SEOHelperTest < ActionView::TestCase
  include SEOHelper

  def default_image
    { url: "https://example.com/default.jpg" }
  end

  test "seo_meta_tags returns HTML string with meta tags" do
    result = seo_meta_tags(
      title: "Test Page",
      description: "This is a test page",
      image: default_image,
      url: "https://example.com/test"
    )

    assert_instance_of ActiveSupport::SafeBuffer, result
    assert result.include?("meta")
  end

  test "seo_meta_tags includes title" do
    result = seo_meta_tags(
      title: "Test Page",
      description: "Description",
      image: default_image,
      url: "https://example.com"
    )

    # Should include Twitter title tag
    assert_match(/twitter:title/, result)
    assert_match(/Test Page/, result)

    # Should include OG title tag
    assert_match(/og:title/, result)
  end

  test "seo_meta_tags includes description" do
    description = "This is a test description"
    result = seo_meta_tags(
      title: "Test",
      description: description,
      image: default_image,
      url: "https://example.com"
    )

    # Should include meta description
    assert_match(/name="description"/, result)
    assert_match(/#{description}/, result)

    # Should include Twitter description
    assert_match(/twitter:description/, result)

    # Should include OG description
    assert_match(/og:description/, result)
  end

  test "seo_meta_tags includes canonical link" do
    url = "https://example.com/test"
    result = seo_meta_tags(
      title: "Test",
      description: "Description",
      image: default_image,
      url: url
    )

    assert_match(/rel="canonical"/, result)
    assert_match(/href="#{Regexp.escape(url)}"/, result)
  end

  test "seo_meta_tags includes Twitter card tags" do
    result = seo_meta_tags(
      title: "Test",
      description: "Description",
      image: default_image,
      url: "https://example.com"
    )

    # Should have Twitter card type
    assert_match(/twitter:card/, result)
    assert_match(/summary/, result)

    # Should have Twitter creator
    assert_match(/twitter:creator/, result)
    assert_match(/@monorkin/, result)
  end

  test "seo_meta_tags includes Open Graph tags" do
    result = seo_meta_tags(
      title: "Test",
      description: "Description",
      image: default_image,
      url: "https://example.com",
      type: "article"
    )

    # Should have OG type
    assert_match(/og:type/, result)
    assert_match(/article/, result)

    # Should have OG locale
    assert_match(/og:locale/, result)
    assert_match(/en_US/, result)

    # Should have OG URL
    assert_match(/og:url/, result)
  end

  test "seo_meta_tags includes image url from hash" do
    image_url = "https://example.com/image.jpg"
    result = seo_meta_tags(
      title: "Test",
      description: "Description",
      image: { url: image_url },
      url: "https://example.com"
    )

    assert_match(/twitter:image/, result)
    assert_match(/#{Regexp.escape(image_url)}/, result)

    assert_match(/og:image/, result)
  end

  test "seo_meta_tags includes image dimensions when provided" do
    result = seo_meta_tags(
      title: "Test",
      description: "Description",
      image: { url: "https://example.com/image.jpg", width: 512, height: 512 },
      url: "https://example.com"
    )

    assert_match(/og:image:width/, result)
    assert_match(/og:image:height/, result)
    assert_match(/512/, result)
  end

  test "seo_meta_tags omits image dimensions when not provided" do
    result = seo_meta_tags(
      title: "Test",
      description: "Description",
      image: { url: "https://example.com/image.jpg" },
      url: "https://example.com"
    )

    assert_no_match(/og:image:width/, result)
    assert_no_match(/og:image:height/, result)
  end

  test "seo_meta_tags uses custom type when provided" do
    result = seo_meta_tags(
      title: "Test",
      description: "Description",
      image: default_image,
      url: "https://example.com",
      type: "article"
    )

    assert_match(/og:type/, result)
    assert_match(/article/, result)
  end

  test "seo_meta_tags defaults to website type" do
    result = seo_meta_tags(
      title: "Test",
      description: "Description",
      image: default_image,
      url: "https://example.com"
    )

    assert_match(/og:type/, result)
    assert_match(/website/, result)
  end

  test "noindex_meta_tag returns robots noindex tag" do
    result = noindex_meta_tag

    assert_match(/name="robots"/, result)
    assert_match(/content="noindex, nofollow"/, result)
  end
end
