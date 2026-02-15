# frozen_string_literal: true

require "test_helper"

class TaggableTest < ActiveSupport::TestCase
  test ".sanitize_tags normalizes and deduplicates tags" do
    result = Taggable.sanitize_tags("Ruby", " ruby ", "RUBY")

    assert_equal ["ruby"], result
  end

  test ".sanitize_tags flattens nested arrays" do
    result = Taggable.sanitize_tags(["ruby", ["elixir", "go"]])

    assert_equal %w[ruby elixir go], result
  end

  test ".tagged_with returns entries with the given tag" do
    tagged = Entry.tagged_with("people")

    assert tagged.any?, "Should find entries tagged with 'people'"
    assert tagged.all? { _1.tags.map(&:name).include?("people") },
           "All results should have the tag"
  end

  test ".tagged_with returns no results for unknown tag" do
    assert_empty Entry.tagged_with("nonexistent")
  end

  test "#tag assigns existing tags" do
    entry = entries(:misguided_mark_entry)

    entry.tag("ruby")

    assert entry.taggings.any? { _1.tag.name == "ruby" },
           "Should assign existing tag"
  end

  test "#tag creates new tags" do
    entry = entries(:misguided_mark_entry)

    entry.tag("brand-new-tag")

    assert entry.taggings.any? { _1.tag.name == "brand-new-tag" },
           "Should create and assign new tag"
  end

  test "#tag does not duplicate already assigned tags" do
    entry = entries(:misguided_mark_entry)
    original_count = entry.taggings.size

    entry.tag("people")

    assert_equal original_count, entry.taggings.size,
                 "Should not duplicate an already assigned tag"
  end

  test "#tags= with string replaces all tags" do
    entry = entries(:misguided_mark_entry)

    entry.tags = "ruby,elixir"
    entry.save!

    tag_names = entry.reload.tags.map(&:name)
    assert_includes tag_names, "ruby"
    assert_includes tag_names, "elixir"
    assert_not_includes tag_names, "people",
                        "Should have replaced the previous tags"
  end
end
