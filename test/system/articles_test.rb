# frozen_string_literal: true

require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "the index page lists articles" do
    visit articles_url

    assert_text articles(:misguided_mark).title
  end

  test "the show page displays an article" do
    article = articles(:misguided_mark)

    visit articles_url

    assert_text article.title
    find("a[href='#{article_path(article)}']").click

    assert_text article.title
  end

  test "infinite scroll loads more articles" do
    visit articles_url

    # First page should be displayed
    assert_selector "li", minimum: 12

    # Scroll to the bottom to trigger infinite scroll
    scroll_to :bottom
    sleep 1

    # A second page should have loaded via turbo-frame
    assert_selector "turbo-frame", minimum: 1
  end
end
