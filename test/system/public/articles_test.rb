require 'application_system_test_case'

class Public::AboutTest < ApplicationSystemTestCase
  test 'the index page should pass all accessibility criteria wihtout articles' do
    visit public_articles_url

    assert_accessible(page)
  end

  test 'the index page should pass all accessibility criteria with less than one page of articles' do
    3.times do |i|
      Article.create!(title: "#{Faker::Book.title} (#{i})",
                      content: Faker::Markdown.sandwich(sentences: 500),
                      publish_at: 1.day.ago,
                      published: true)
    end

    visit public_articles_url

    assert_selector 'article.articles_list__article'
    assert_accessible(page)
  end

  test 'the index page should pass all accessibility criteria on all pages' do
    30.times do |i|
      Article.create!(title: "#{Faker::Book.title} (#{i})",
                      content: Faker::Markdown.sandwich(sentences: 50),
                      publish_at: 1.day.ago,
                      published: true)
    end

    visit public_articles_url

    assert_selector 'article.articles_list__article'
    assert_accessible(page)

    click_link 'Older articles'

    assert_selector 'article.articles_list__article'
    assert_accessible(page)
  end

  test 'the show page has no accessibility issues' do
    article = Article.create!(title: Faker::Book.title,
                              content: Faker::Markdown.sandwich(sentences: 500),
                              publish_at: 1.day.ago,
                              published: true)

    visit public_articles_url(article)
    assert_accessible(page)
  end
end
