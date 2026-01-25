# frozen_string_literal: true

require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  fixtures :articles, :entries, "action_text/rich_texts"

  test "#to_param returns the entry's slug" do
    article = articles(:misguided_mark)
    entry = entries(:misguided_mark_entry)

    assert_equal entry.to_param, article.to_param, "Should return the entry's to_param"
  end

  test "#excerpt returns the first 300 characters of the plain text content" do
    article = articles(:misguided_mark)

    article.content.body = "Lore ipsum dolor sit amet, consectetur adipiscing elit. " * 10

    assert_equal("#{article.plain_text[0...296]}...", article.excerpt,
                 "Should return the first 300 characters of the plain text content")
    assert_equal("#{article.plain_text[0...38]}...", article.excerpt(length: 50),
                 "Should return the first 50 characters of the plain text content when passed a length")
  end

  test "#estimated_reading_time returns the estimated reading time in minutes" do
    article = articles(:misguided_mark)

    assert_equal 8, article.estimated_reading_time,
                 "Should return the estimated reading time in minutes"

    assert_equal 3, article.estimated_reading_time(words_per_minute: 650),
                 "Should return the estimated reading time in minutes based on the given reading speed"

    article.content.body = ""
    assert_equal 1, article.estimated_reading_time, "Should return 0 if the article is empty"
  end

  test "#plain_text returns the plain text content" do
    article = articles(:misguided_mark)

    article.content.body = "<p>Some <strong>bold</strong> text</p>"

    assert_equal "Some bold text", article.plain_text, "Should return the plain text content"
  end

  test "#related_articles returns articles with shared tags" do
    article = articles(:misguided_mark)

    related = article.related_articles(limit: 5)

    assert_kind_of ActiveRecord::Relation, related
    assert related.none? { |a| a.id == article.id }, "Should not include the article itself"
  end

  test "#previous_article returns the article published before" do
    article = articles(:hold_your_own_poison_ivy)

    previous = article.previous_article

    assert_not_nil previous
    assert previous.published_at < article.published_at, "Previous article should be older"
  end

  test "#next_article returns the article published after" do
    article = articles(:misguided_mark)

    next_article = article.next_article

    assert_not_nil next_article
    assert next_article.published_at > article.published_at, "Next article should be newer"
  end

  test ".popular returns the most recent published articles" do
    popular = Article.popular(limit: 5)

    assert_equal 5, popular.count
    assert popular.all?(&:published?), "All articles should be published"
  end

  test "#published? delegates to entry" do
    article = articles(:misguided_mark)
    entry = entries(:misguided_mark_entry)

    assert_equal entry.published?, article.published?
  end

  test "#published_at delegates to entry" do
    article = articles(:misguided_mark)
    entry = entries(:misguided_mark_entry)

    assert_equal entry.published_at, article.published_at
  end
end
