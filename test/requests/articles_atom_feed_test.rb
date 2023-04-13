# frozen_string_literal: true

require "test_helper"

class ArticlesAtomFeedTest < ActionDispatch::IntegrationTest
  fixtures :articles, "action_text/rich_texts"

  test "/articles/atom" do
    get atom_articles_path

    feed = Nokogiri::XML(response.body)

    # The respons is a valid Atom feed
    assert_equal "http://www.w3.org/2005/Atom", feed.root.namespace.href

    # The feed has the correct discovery links
    assert_equal "http://www.example.com/articles", feed.css("feed > link[rel='alternate']")[0]["href"]
    assert_equal "http://www.example.com/articles/atom", feed.css("feed > link[rel='self']")[0]["href"]

    # The feed has the correct title
    assert_equal "Stanko Krtalic Rusendic", feed.css("feed > title").text

    # The feed has the correct updated date
    assert_equal articles(:misguided_mark).updated_at.iso8601, feed.css("feed > updated").text

    # The feed has the correct number of entries
    assert_equal 2, feed.css("feed > entry").size

    # The feed retuns entries in the correct order
    assert_equal articles(:misguided_mark).id, feed.css("feed > entry > id").first.text.split("/").last.to_i
    assert_equal articles(:render_test).id, feed.css("feed > entry > id").last.text.split("/").last.to_i

    # The feed has the correct fields and values for entries
    feed.css("feed > entry").each do |entry|
      assert_equal 1, entry.css("id").size, "Entry has just one id"

      article = Article.find(entry.css("id").text.split("/").last.to_i)

      assert_equal 1, entry.css("title").size, "Entry has just one title"
      assert_equal article.title, entry.css("title").text

      assert_equal 1, entry.css("content").size, "Entry has just one content"
      assert_equal article.content.to_s, entry.css("content").text

      assert_equal 1, entry.css("published").size, "Entry has just one published date"
      assert_equal article.published_at.iso8601, entry.css("published").text

      assert_equal 1, entry.css("author").size, "Entry has just one author"

      author = entry.css("author").first

      assert_equal 1, author.css("name").size, "Author has just one name"
      assert_equal "Stanko Krtalic Rusendic", author.css("name").text

      assert_equal 1, author.css("email").size, "Author has just one email"
      assert_equal "hey@stanko.io", author.css("email").text
    end
  end
end
