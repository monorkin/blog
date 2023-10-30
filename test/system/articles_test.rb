# frozen_string_literal: true

require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  fixtures :articles, "action_text/rich_texts"

  test "the index page should pass all accessibility criteria with articles present" do
    visit articles_url

    click_link "Older articles"
    assert_accessible(page)

    click_link "Newer articles"
    assert_accessible(page)
  end

  test "the index page should pass all accessibility criteria wihtout articles" do
    Article.all.destroy_all

    visit articles_url

    assert_accessible(page)
  end

  test "the show page has no accessibility issues" do
    article = articles(:misguided_mark)

    visit articles_url

    assert_text article.title
    find("a[href='#{article_path(article)}']").click

    assert_accessible(page)
  end
end
