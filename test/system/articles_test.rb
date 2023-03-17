# frozen_string_literal: true

require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  test 'the index page should pass all accessibility criteria with articles present' do
    50.times do |i|
      Article.create!(title: "#{Faker::Book.title} (#{i})",
                      content: Faker::Markdown.sandwich(sentences: 50),
                      publish_at: i.days.ago,
                      published: true)
    end

    visit articles_url

    assert_selector 'article.article.article--list-item'
    assert_accessible(page)

    click_link 'Next Page'

    assert_selector 'article.article.article--list-item'
    assert_accessible(page)

    click_link 'Previous Page'
  end

  test 'the index page should pass all accessibility criteria wihtout articles' do
    visit articles_url

    assert_accessible(page)
  end

  test 'the show page has no accessibility issues' do
    article = Article.create!(title: Faker::Book.title,
                              content: [
                                Faker::Markdown.headers,
                                Faker::Markdown.emphasis,
                                Faker::Markdown.sandwich(sentences: 10),
                                Faker::Markdown.headers,
                                Faker::Markdown.ordered_list,
                                Faker::Markdown.sandwich(sentences: 10),
                                Faker::Markdown.headers,
                                Faker::Markdown.unordered_list,
                                Faker::Markdown.sandwich(sentences: 10),
                                Faker::Markdown.headers,
                                Faker::Markdown.inline_code,
                                Faker::Markdown.sandwich(sentences: 10),
                                Faker::Markdown.headers,
                                Faker::Markdown.block_code,
                                Faker::Markdown.sandwich(sentences: 10),
                                Faker::Markdown.headers,
                                Faker::Markdown.table,
                                Faker::Markdown.sandwich(sentences: 10),
                                Faker::Markdown.headers,
                                "> This is a block quote\n\n> It is cool",
                                Faker::Markdown.sandwich(sentences: 10),
                                Faker::Markdown.headers,
                                "![This is an image](#{Faker::LoremFlickr.image})",
                                Faker::Markdown.sandwich(sentences: 10)
                              ].join("\n\n"),
                              publish_at: 1.day.ago,
                              published: true)
    visit articles_url

    click_link article.title

    assert_accessible(page)
  end
end
