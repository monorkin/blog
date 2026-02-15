# frozen_string_literal: true

require "test_helper"

class EntryTest < ActiveSupport::TestCase
  test ".with_types filters by entryable type" do
    articles_only = Entry.with_types([:article])
    talks_only = Entry.with_types([:talk])

    assert articles_only.all? { _1.entryable_type == "Article" },
           "Should only return Article entries"
    assert talks_only.all? { _1.entryable_type == "Talk" },
           "Should only return Talk entries"
  end

  test ".with_types accepts multiple types" do
    both = Entry.with_types(%i[article talk])

    types = both.map(&:entryable_type).uniq.sort
    assert_equal %w[Article Talk], types, "Should return both Article and Talk entries"
  end

  test ".by_recency orders by published_at descending" do
    entries = Entry.by_recency.limit(5)

    entries.each_cons(2) do |a, b|
      assert a.published_at >= b.published_at, "Entries should be ordered newest first"
    end
  end

  test "#title delegates to entryable" do
    entry = entries(:misguided_mark_entry)

    assert_equal entry.entryable.title, entry.title
  end

  test "#content delegates to entryable" do
    entry = entries(:misguided_mark_entry)

    assert_kind_of ActionText::Content, entry.content
  end

  test "#excerpt delegates to entryable" do
    entry = entries(:misguided_mark_entry)

    assert_equal entry.entryable.excerpt, entry.excerpt
  end

  test "#seo returns an Entry::SEO instance" do
    entry = entries(:misguided_mark_entry)

    assert_kind_of Entry::SEO, entry.seo
  end

  test "#seo is memoized" do
    entry = entries(:misguided_mark_entry)

    assert_same entry.seo, entry.seo
  end
end
