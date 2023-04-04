# frozen_string_literal: true

require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  fixtures :articles, "action_text/rich_texts"

  test 'the index page should pass all accessibility criteria with articles present' do
    50.times do |i|
      Article.create!(title: "#{Faker::Book.title} (#{i})",
                      content: Faker::Markdown.sandwich(sentences: 50),
                      publish_at: i.days.ago,
                      published: true)
    end

    visit articles_url

    click_link 'Next Page'

    click_link 'Previous Page'
  end

  test 'the index page should pass all accessibility criteria wihtout articles' do
    visit articles_url

    assert_accessible(page)
  end

  test 'the show page has no accessibility issues' do
    article = articles(:misguided_mark)

    visit articles_url

    assert_text article.title
    find("a[href='#{article_path(article)}']").click

    assert_accessible(page)
  end
end
