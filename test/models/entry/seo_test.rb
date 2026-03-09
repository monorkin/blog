# frozen_string_literal: true

require "test_helper"

class Entry::SEOTest < ActiveSupport::TestCase
  test "#title includes the entry title and site name" do
    entry = entries(:misguided_mark_entry)
    seo = entry.seo

    assert_includes seo.title, "Stanko K.R."
    assert_includes seo.title, entry.title.truncate(Entry::SEO::TITLE_MAX_LENGTH, separator: " ")
  end

  test "#title truncates long entry titles" do
    entry = entries(:misguided_mark_entry)
    seo = entry.seo

    assert seo.title.length <= Entry::SEO::RECOMMENDED_TITLE_MAX_LENGTH + 10,
           "SEO title should stay within a reasonable length"
  end

  test "#description returns the entry excerpt" do
    entry = entries(:misguided_mark_entry)
    seo = entry.seo

    assert_equal entry.excerpt(length: Entry::SEO::DESCRIPTION_MAX_LENGTH), seo.description
  end

  test "#og_type returns article" do
    entry = entries(:misguided_mark_entry)

    assert_equal "article", entry.seo.og_type
  end

  test "#image returns an Entry::SEO::Image" do
    entry = entries(:misguided_mark_entry)

    assert_kind_of Entry::SEO::Image, entry.seo.image
  end

  test "#image does not raise for video snaps" do
    entry = entries(:robin_entry)

    assert entry.cover_image.video?, "Fixture should have a video attachment"
    assert_nothing_raised { entry.seo.image.to_h }
  end

  test "#image returns image data for image snaps" do
    entry = entries(:hiking_hut_entry)

    assert entry.cover_image.image?, "Fixture should have an image attachment"
    assert_not_equal Entry::SEO::Image.default, entry.seo.image.to_h,
      "Image attachments should return actual image data"
  end

  test "#canonical_url returns the entryable URL" do
    entry = entries(:misguided_mark_entry)
    seo = entry.seo

    assert_includes seo.canonical_url, entry.entryable.to_param
  end
end
