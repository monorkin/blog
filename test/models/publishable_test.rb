# frozen_string_literal: true

require "test_helper"

class PublishableTest < ActiveSupport::TestCase
  test ".published returns entries that are published and in the past" do
    published = Entry.published

    assert published.all?(&:published?), "Should only include published entries"
  end

  test ".published excludes entries with future published_at" do
    entry = entries(:misguided_mark_entry)
    entry.update_columns(published_at: 1.day.from_now)

    assert_not_includes Entry.published, entry,
                        "Should not include entries with future published_at"
  end

  test ".published excludes unpublished entries" do
    entry = entries(:misguided_mark_entry)
    entry.update_columns(published: false)

    assert_not_includes Entry.published, entry,
                        "Should not include unpublished entries"
  end

  test "#published? returns true when published and published_at is in the past" do
    entry = entries(:misguided_mark_entry)

    assert entry.published?
  end

  test "#published? returns false when not published" do
    entry = entries(:misguided_mark_entry)
    entry.published = false

    assert_not entry.published?
  end

  test "#published? returns false when published_at is in the future" do
    entry = entries(:misguided_mark_entry)
    entry.published_at = 1.day.from_now

    assert_not entry.published?
  end

  test "sets published_at on save when not set" do
    article = Article.new(title: "New article", body: "Content", published: true)

    article.save!

    assert_not_nil article.entry.published_at, "Should set published_at on save"
  end
end
