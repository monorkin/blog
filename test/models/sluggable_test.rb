# frozen_string_literal: true

require "test_helper"

class SluggableTest < ActiveSupport::TestCase
  test ".from_slug! finds an entry by slug_id" do
    entry = entries(:misguided_mark_entry)

    found = Entry.from_slug!(entry.to_param)

    assert_equal entry, found
  end

  test ".from_slug! finds entry regardless of slug prefix" do
    entry = entries(:misguided_mark_entry)

    found = Entry.from_slug!("any-prefix-#{entry.slug_id}")

    assert_equal entry, found
  end

  test ".from_slug! raises RecordNotFound for blank slug" do
    assert_raises(ActiveRecord::RecordNotFound) { Entry.from_slug!("") }
    assert_raises(ActiveRecord::RecordNotFound) { Entry.from_slug!(nil) }
  end

  test ".from_slug! raises RecordNotFound for unknown slug" do
    assert_raises(ActiveRecord::RecordNotFound) { Entry.from_slug!("does-not-exist") }
  end

  test ".from_slug returns nil instead of raising" do
    assert_nil Entry.from_slug("does-not-exist")
  end

  test ".from_slug returns the entry when found" do
    entry = entries(:misguided_mark_entry)

    assert_equal entry, Entry.from_slug(entry.to_param)
  end

  test "#to_param combines slug and slug_id" do
    entry = entries(:misguided_mark_entry)

    assert_equal "#{entry.slug}-#{entry.slug_id}", entry.to_param
  end

  test "generates slug from title on create" do
    article = Article.create!(title: "My Great Article", body: "Content")

    assert_equal "my-great-article", article.entry.slug
  end

  test "generates a unique slug_id on create" do
    article = Article.create!(title: "Some article", body: "Content")

    assert_not_nil article.entry.slug_id
    assert_equal 12, article.entry.slug_id.length
  end

  test "validates slug_id uniqueness" do
    existing = entries(:misguided_mark_entry)
    entry = Entry.new(slug: "test", slug_id: existing.slug_id, entryable: talks(:do_you_really_need_websockets_webcamp_2018))
    entry.valid?

    assert entry.errors[:slug_id].any?, "Should require unique slug_id"
  end
end
