# frozen_string_literal: true

require "test_helper"

class EntryableTest < ActiveSupport::TestCase
  test ".with_entry joins and preloads the entry" do
    articles = Article.with_entry.where(id: articles(:misguided_mark).id)

    assert_equal 1, articles.size
    assert articles.first.association(:entry).loaded?, "Should preload the entry association"
  end

  test ".published returns only published entryables" do
    published_articles = Article.published

    assert published_articles.all?(&:published?), "Should only return published articles"
  end

  test ".tagged_with returns entryables tagged with the given tag" do
    tagged = Article.published.tagged_with("people")

    assert tagged.any?, "Should find articles tagged with 'people'"
    assert tagged.all? { |a| a.tags.map(&:name).include?("people") },
           "All returned articles should have the 'people' tag"
  end

  test ".tagged_with returns no results for a non-existent tag" do
    tagged = Article.published.tagged_with("nonexistent")

    assert_empty tagged, "Should return no articles for a tag that doesn't exist"
  end

  test ".tagged_with works on Talk as well" do
    tagged = Talk.published.tagged_with("people")

    assert_kind_of ActiveRecord::Relation, tagged
  end

  test "#to_param delegates to entry" do
    article = articles(:misguided_mark)
    entry = entries(:misguided_mark_entry)

    assert_equal entry.to_param, article.to_param
  end

  test "#published? delegates to entry" do
    article = articles(:misguided_mark)

    assert_equal article.entry.published?, article.published?
  end

  test "#published_at delegates to entry" do
    article = articles(:misguided_mark)

    assert_equal article.entry.published_at, article.published_at
  end

  test "#publish_at delegates to entry" do
    article = articles(:misguided_mark)

    assert_equal article.entry.publish_at, article.publish_at
  end

  test "#tags delegates to entry" do
    article = articles(:misguided_mark)

    assert_equal article.entry.tags.to_a, article.tags.to_a
  end

  test "#published= writes through to the entry" do
    article = articles(:misguided_mark)

    article.published = false

    assert_equal false, article.entry.published
  end

  test "#publish_at= writes through to the entry" do
    article = articles(:misguided_mark)
    time = 1.week.from_now

    article.publish_at = time

    assert_in_delta time, article.entry.publish_at, 1.second
  end

  test "#tags= writes through to the entry" do
    article = articles(:misguided_mark)

    article.tags = "ruby,elixir"

    tag_names = article.entry.taggings.map { _1.tag.name }
    assert_includes tag_names, "ruby"
    assert_includes tag_names, "elixir"
  end

  test "#published= builds an entry if none exists" do
    article = Article.new(title: "New article", body: "Content")
    article.entry = nil

    article.published = true

    assert_not_nil article.entry, "Should build an entry when setting published"
  end

  test "#publish_at= builds an entry if none exists" do
    article = Article.new(title: "New article", body: "Content")
    article.entry = nil

    article.publish_at = 1.week.from_now

    assert_not_nil article.entry, "Should build an entry when setting publish_at"
  end

  test "#tags= builds an entry if none exists" do
    article = Article.new(title: "New article", body: "Content")
    article.entry = nil

    article.tags = "ruby"

    assert_not_nil article.entry, "Should build an entry when setting tags"
  end

  test "#content returns ActionText::Content" do
    article = articles(:misguided_mark)

    assert_kind_of ActionText::Content, article.content
  end

  test "#plain_text_content strips HTML and bracketed text" do
    article = articles(:misguided_mark)
    article.body = "<p>Hello [world]</p>"

    assert_equal "Hello ", article.plain_text_content
  end

  test "#excerpt truncates plain text content" do
    article = articles(:misguided_mark)
    article.body = "Word " * 100

    excerpt = article.excerpt(length: 50)

    assert excerpt.length <= 50, "Excerpt should not exceed the given length"
    assert excerpt.ends_with?("..."), "Excerpt should end with ellipsis"
  end

  test "#excerpt returns nil for blank content" do
    article = articles(:misguided_mark)
    article.body = ""

    assert_nil article.excerpt
  end

  test "#slug derives from title" do
    article = Article.new(title: "Hello World")

    assert_equal "hello-world", article.slug
  end
end
