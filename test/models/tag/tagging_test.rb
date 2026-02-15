# frozen_string_literal: true

require "test_helper"

class Tag::TaggingTest < ActiveSupport::TestCase
  test "touches both the tag and the taggable after create" do
    tag = tags(:ruby)
    taggable = entries(:hold_your_own_poison_ivy_entry)

    old_tag_updated_at = tag.updated_at
    old_taggable_updated_at = taggable.updated_at

    tag.taggings.create!(taggable: taggable)

    assert_not_equal old_tag_updated_at, tag.reload.updated_at
    assert_not_equal old_taggable_updated_at, taggable.reload.updated_at
  end

  test "validates uniqueness of tag per taggable" do
    existing = tag_taggings(:people_on_misguided_mark)

    duplicate = Tag::Tagging.new(
      tag: existing.tag,
      taggable: existing.taggable
    )

    assert_not duplicate.valid?
    assert duplicate.errors[:tag_id].any?, "Should not allow duplicate tag on same taggable"
  end
end
