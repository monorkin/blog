# frozen_string_literal: true

require "test_helper"

class SnapTest < ActiveSupport::TestCase
  test "#to_param delegates to entry" do
    snap = snaps(:sky_1)

    assert_equal snap.entry.to_param, snap.to_param
  end

  test "validates title presence" do
    snap = Snap.new(title: "")

    assert_not snap.valid?
    assert snap.errors[:title].any?, "Should have title validation error"
  end

  test "#content returns empty ActionText::Content" do
    snap = snaps(:sky_1)

    content = snap.content

    assert_kind_of ActionText::Content, content
    assert_equal "", content.to_plain_text
  end

  test "auto-publishes on create" do
    snap = Snap.new(title: "Test Snap")

    snap.valid?

    assert snap.entry.published, "New snaps should be auto-published"
  end
end
