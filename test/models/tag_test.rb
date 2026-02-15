# frozen_string_literal: true

require "test_helper"

class TagTest < ActiveSupport::TestCase
  test ".normalize_value_for :name" do
    assert_equal "foo", Tag.normalize_value_for(:name, "foo")
    assert_equal "foo", Tag.normalize_value_for(:name, "FOO")
    assert_equal "foo", Tag.normalize_value_for(:name, " Foo ")
    assert_equal "foo", Tag.normalize_value_for(:name, "  Foo  ")
    assert_equal "foo", Tag.normalize_value_for(:name, "  foo  ")
    assert_equal "foo", Tag.normalize_value_for(:name, "  FOO  ")

    assert_equal "foo-bar", Tag.normalize_value_for(:name, "foo-bar")
    assert_equal "foo-bar", Tag.normalize_value_for(:name, "foo bar")
    assert_equal "foo-bar", Tag.normalize_value_for(:name, " foo  bar ")
    assert_equal "foo-bar", Tag.normalize_value_for(:name, "Foo Bar")
    assert_equal "foo-bar", Tag.normalize_value_for(:name, "Foo-Bar")
    assert_equal "foo-bar", Tag.normalize_value_for(:name, "FOO-Bar")
    assert_equal "foo-bar", Tag.normalize_value_for(:name, "FOO-BAR")
    assert_equal "foo-bar", Tag.normalize_value_for(:name, "Foo-BAR")

    assert_equal "foo-bar-baz", Tag.normalize_value_for(:name, "foo bar/baz")
    assert_equal "foo-bar-baz", Tag.normalize_value_for(:name, "foo bar+baz")
    assert_equal "foo-bar-baz", Tag.normalize_value_for(:name, "foo bar&baz")
    assert_equal "foo-bar-baz", Tag.normalize_value_for(:name, "foo bar_baz")
    assert_equal "foo-bar-baz", Tag.normalize_value_for(:name, "foo bar & baz")
  end

  test ".suggest returns tags matching the prefix" do
    suggestions = Tag.suggest("rub")

    assert_includes suggestions, "ruby"
  end

  test ".suggest returns empty for blank query" do
    assert_empty Tag.suggest("")
  end

  test ".suggest respects limit" do
    suggestions = Tag.suggest("", limit: 2)

    assert_empty suggestions
  end

  test ".suggest normalizes the query" do
    suggestions = Tag.suggest("RUB")

    assert_includes suggestions, "ruby"
  end

  test "#to_param returns the tag name" do
    tag = tags(:ruby)

    assert_equal "ruby", tag.to_param
  end

  test "#published_entries_count returns count of published entries" do
    tag = tags(:ruby)

    count = tag.published_entries_count

    assert_kind_of Integer, count
    assert count >= 1, "Should count at least one published entry"
  end

  test "#related_tags returns tags that share entries" do
    tag = tags(:people)

    related = tag.related_tags

    assert_kind_of ActiveRecord::Relation, related
    assert related.none? { _1.id == tag.id }, "Should not include itself"
  end

  test "validates name presence" do
    tag = Tag.new(name: "")

    assert_not tag.valid?
    assert tag.errors[:name].any?
  end

  test "validates name uniqueness" do
    duplicate = Tag.new(name: tags(:ruby).name)

    assert_not duplicate.valid?
    assert duplicate.errors[:name].any?
  end
end
