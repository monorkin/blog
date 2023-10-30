require "test_helper"

class Tag::TaggingTest < ActiveSupport::TestCase
  fixtures :tags, "tag/taggings", :articles

  test "touches both the tag and the taggable after create" do
    tag = tags(:ruby)
    taggable = articles(:hold_your_own_poison_ivy)

    old_tag_updated_at = tag.updated_at
    old_taggable_updated_at = taggable.updated_at

    tag.taggings.create!(taggable: taggable)

    assert_not_equal old_tag_updated_at, tag.reload.updated_at
    assert_not_equal old_taggable_updated_at, taggable.reload.updated_at
  end
end
