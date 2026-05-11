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

  test "clicking an article link from a paginated page navigates to the article" do
    visit articles_url

    # Trigger infinite scroll to load the second page (wrapped in a turbo-frame)
    scroll_to :bottom
    sleep 1

    frame = find("turbo-frame[id^='articles_page_']")
    link = frame.first("li a[href^='/']")
    target_href = link[:href]

    link.click

    assert_current_path URI.parse(target_href).path
    assert_no_text "Content missing"
    assert_selector "h1"
  end
end
