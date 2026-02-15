# frozen_string_literal: true

require "test_helper"

class SearchTest < ActiveSupport::TestCase
  test "#results returns empty array when term is blank" do
    search = Search.new(term: "")

    assert_equal [], search.results
  end

  test "#results returns articles, talks, and tags" do
    search = Search.new(term: "misguided")

    results = search.results

    assert results.key?(:articles), "Should include articles"
    assert results.key?(:talks), "Should include talks"
    assert results.key?(:tags), "Should include tags"
  end

  test "#articles returns matching articles by title" do
    search = Search.new(term: "misguided")

    assert search.articles.any? { _1.title.include?("Misguided") },
           "Should find articles matching the term"
  end

  test "#articles is case-insensitive" do
    search = Search.new(term: "MISGUIDED")

    assert search.articles.any? { _1.title.include?("Misguided") },
           "Should find articles regardless of case"
  end

  test "#articles returns none when term is blank" do
    search = Search.new(term: "")

    assert_empty search.articles
  end

  test "#articles respects result_count" do
    search = Search.new(term: "filler", result_count: 3)

    assert search.articles.size <= 3, "Should not exceed result_count"
  end

  test "#articles searches by tag when term starts with #" do
    search = Search.new(term: "#people")

    articles = search.articles

    assert articles.any?, "Should find articles tagged with 'people'"
    assert articles.all? { _1.tags.map(&:name).include?("people") },
           "All results should be tagged with 'people'"
  end

  test "#talks returns matching talks by title" do
    search = Search.new(term: "WebSockets")

    assert search.talks.any? { _1.title.include?("WebSockets") },
           "Should find talks matching the term"
  end

  test "#talks returns none when term is blank" do
    search = Search.new(term: "")

    assert_empty search.talks
  end

  test "#talks respects result_count" do
    search = Search.new(term: "filler", result_count: 3)

    assert search.talks.size <= 3, "Should not exceed result_count"
  end

  test "#tags returns matching tags" do
    search = Search.new(term: "ruby")

    assert search.tags.any? { _1.name == "ruby" },
           "Should find tags matching the term"
  end

  test "#tags returns none when term is blank" do
    search = Search.new(term: "")

    assert_empty search.tags
  end

  test "#tags returns none when term starts with #" do
    search = Search.new(term: "#ruby")

    assert_empty search.tags, "Should not search tags when filtering by tag"
  end

  test "#result_count defaults to 5" do
    search = Search.new

    assert_equal 5, search.result_count
  end
end
