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

  test "#content returns caption as ActionText::Content" do
    snap = snaps(:sky_1)

    content = snap.content

    assert_kind_of ActionText::Content, content
    assert_equal "The sky on fire", content.to_plain_text
  end

  test "#content returns empty ActionText::Content when caption is blank" do
    snap = snaps(:sky_2)

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
