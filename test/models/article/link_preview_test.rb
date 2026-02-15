# frozen_string_literal: true

require "test_helper"

class Article::LinkPreviewTest < ActiveSupport::TestCase
  test "#fetched? returns false when title and description are blank" do
    preview = Article::LinkPreview.new(article: articles(:misguided_mark), url: "https://example.com")

    assert_not preview.fetched?
  end

  test "#fetched? returns true when title is present" do
    preview = Article::LinkPreview.new(
      article: articles(:misguided_mark),
      url: "https://example.com",
      title: "Example"
    )

    assert preview.fetched?
  end

  test "#fetched? returns true when description is present" do
    preview = Article::LinkPreview.new(
      article: articles(:misguided_mark),
      url: "https://example.com",
      description: "A description"
    )

    assert preview.fetched?
  end

  test "#image? returns false when no image is attached" do
    preview = Article::LinkPreview.new(article: articles(:misguided_mark), url: "https://example.com")

    assert_not preview.image?
  end

  test "normalizes title by stripping and truncating" do
    preview = Article::LinkPreview.new(
      article: articles(:misguided_mark),
      url: "https://example.com",
      title: "  #{"a" * 300}  "
    )

    assert_equal 255, preview.title.length
    assert_not preview.title.start_with?(" "), "Should strip whitespace"
  end

  test "normalizes description by stripping and truncating" do
    preview = Article::LinkPreview.new(
      article: articles(:misguided_mark),
      url: "https://example.com",
      description: "  #{"a" * 1100}  "
    )

    assert_equal 1000, preview.description.length
    assert_not preview.description.start_with?(" "), "Should strip whitespace"
  end
end
