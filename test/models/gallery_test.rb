# frozen_string_literal: true

require "test_helper"

class GalleryTest < ActiveSupport::TestCase
  test "validates title presence" do
    gallery = Gallery.new(title: "")

    assert_not gallery.valid?
    assert gallery.errors[:title].any?, "Should have title validation error"
  end

  test "#multi? returns true when gallery has multiple snaps" do
    gallery = galleries(:hiking_gallery)

    assert gallery.multi?, "Hiking gallery should have multiple snaps"
  end

  test "#multi? returns false when gallery has a single snap" do
    gallery = galleries(:sky_1_gallery)

    assert_not gallery.multi?, "Single-snap gallery should not be multi"
  end

  test "#cover_snaps returns first N snaps with attached files" do
    gallery = galleries(:hiking_gallery)

    covers = gallery.cover_snaps(2)

    assert_equal 2, covers.size, "Should return 2 cover snaps"
  end

  test "#latest_published_at returns most recent snap published_at" do
    gallery = galleries(:hiking_gallery)

    latest = gallery.latest_published_at

    assert_not_nil latest, "Should return a published_at timestamp"
  end
end
