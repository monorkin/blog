# frozen_string_literal: true

require "test_helper"

class ArticlesAtomFeedTest < ActionDispatch::IntegrationTest
  fixtures :articles, :entries, :talks, "action_text/rich_texts"

  test "/articles/atom redirects to /feed with types=article" do
    get atom_articles_path

    assert_redirected_to "/feed?types=article"
  end

  test "/articles/atom?tag=ruby redirects to /feed with types=article&tag=ruby" do
    get atom_articles_path(tag: "ruby")

    assert_redirected_to "/feed?tag=ruby&types=article"
  end

  test "/feed returns valid Atom feed" do
    get feed_path

    feed = Nokogiri::XML(response.body)

    # The response is a valid Atom feed
    assert_equal "http://www.w3.org/2005/Atom", feed.root.namespace.href

    # The feed has the correct title
    assert_equal "Stanko Krtalic Rusendic", feed.css("feed > title").text

    # The feed has the correct updated date
    assert_equal entries(:hold_your_own_poison_ivy_entry).updated_at.iso8601, feed.css("feed > updated").text

    # The feed has the correct number of entries
    assert_equal Entry.published.count, feed.css("feed > entry").size
  end

  test "/feed?types=article filters to article entries only" do
    get feed_path(types: "article")

    feed = Nokogiri::XML(response.body)

    # Should only show article entries
    article_entries = Entry.published.where(entryable_type: "Article")
    assert_equal article_entries.count, feed.css("feed > entry").size
  end

  test "/feed entries have correct structure" do
    get feed_path

    feed = Nokogiri::XML(response.body)

    # The feed has the correct fields and values for entries
    feed.css("feed > entry").each do |feed_entry|
      assert_equal 1, feed_entry.css("id").size, "Entry has just one id"
      assert_equal 1, feed_entry.css("title").size, "Entry has just one title"
      assert_equal 1, feed_entry.css("content").size, "Entry has just one content"
      assert_equal 1, feed_entry.css("published").size, "Entry has just one published date"
      assert_equal 1, feed_entry.css("author").size, "Entry has just one author"

      author = feed_entry.css("author").first

      assert_equal 1, author.css("name").size, "Author has just one name"
      assert_equal "Stanko Krtalic Rusendic", author.css("name").text

      assert_equal 1, author.css("email").size, "Author has just one email"
      assert_equal "hey@stanko.io", author.css("email").text
    end
  end
end
