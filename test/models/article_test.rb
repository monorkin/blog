# frozen_string_literal: true

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  fixtures :articles, 'action_text/rich_texts', :tags, 'tag/taggings'

  test '.generate_slug_id generates a random 12 chracter code' do
    slug_id = Article.generate_slug_id

    assert_equal 12, slug_id.length, 'Slug id should be 12 characters'
    assert_match(/[a-zA-Z0-9]{12}/, slug_id, 'Slug id should be alphanumeric')
  end

  test ".from_slug finds an article by slug but doesn't raise an error if non was found" do
    article = articles(:misguided_mark)

    assert_equal article, Article.from_slug(article.slug), 'Should find article by slug'
    assert_nil Article.from_slug('non-existent-slug'), 'Should return nil if no article was found'
  end

  test '.from_slug! finds an article by slug and raises an error if non was found' do
    article = articles(:misguided_mark)

    assert_equal article, Article.from_slug!(article.slug), 'Should find article by slug'
    assert_raises ActiveRecord::RecordNotFound do
      Article.from_slug!('non-existent-slug')
    end
  end

  test '#to_param returns the slug' do
    article = articles(:misguided_mark)

    assert_equal article.slug, article.to_param, 'Should return the slug'
  end

  test '#slug returns the slug or generates one from the title' do
    article = articles(:misguided_mark)

    slug = SecureRandom.hex(6)
    article.slug = slug

    assert_match(/^#{slug}/, article.slug, 'Should generate a slug from the title')
    assert_match(/-#{article.slug_id}$/, article.slug, 'Should end with the slug_id')

    article.slug = nil

    assert_match(/^#{article.title.parameterize}/, article.slug,
                 'Should generate a slug from the title')
    assert_match(/-#{article.slug_id}$/, article.slug, 'Should end with the slug_id')
  end

  test '#excerpt returns the first 300 characters of the plain text content' do
    article = articles(:misguided_mark)

    article.content.body = 'Lore ipsum dolor sit amet, consectetur adipiscing elit. ' * 10

    assert_equal("#{article.plain_text[0...296]}...", article.excerpt,
                 'Should return the first 300 characters of the plain text content')
    assert_equal("#{article.plain_text[0...38]}...", article.excerpt(length: 50),
                 'Should return the first 50 characters of the plain text content when passed a length')
  end

  test '#estimated_reading_time returns the estimated reading time in minutes' do
    article = articles(:misguided_mark)

    assert_equal 8, article.estimated_reading_time,
                 'Should return the estimated reading time in minutes'

    assert_equal 3, article.estimated_reading_time(words_per_minute: 650),
                 'Should return the estimated reading time in minutes based on the given reading speed'

    article.content.body = ''
    assert_equal 1, article.estimated_reading_time, 'Should return 0 if the article is empty'
  end

  test '#plain_text returns the plain text content' do
    article = articles(:misguided_mark)

    article.content.body = '<p>Some <strong>bold</strong> text</p>'

    assert_equal 'Some bold text', article.plain_text, 'Should return the plain text content'
  end

  test '#generate_slug_id! generates a random 12 chracter code' do
    article = articles(:misguided_mark)

    article.generate_slug_id!

    assert_equal 12, article.slug_id.length, 'Slug id should be 12 characters'
    assert_match(/[a-zA-Z0-9]{12}/, article.slug_id, 'Slug id should be alphanumeric')
  end

  test '#related_articles returns articles with shared tags' do
    article = articles(:misguided_mark)

    related = article.related_articles(limit: 5)

    assert_kind_of ActiveRecord::Relation, related
    assert related.none? { |a| a.id == article.id }, 'Should not include the article itself'
  end

  test '#previous_article returns the article published before' do
    article = articles(:hold_your_own_poison_ivy)

    previous = article.previous_article

    assert_not_nil previous
    assert previous.published_at < article.published_at, 'Previous article should be older'
  end

  test '#next_article returns the article published after' do
    article = articles(:misguided_mark)

    next_article = article.next_article

    assert_not_nil next_article
    assert next_article.published_at > article.published_at, 'Next article should be newer'
  end

  test '.popular returns the most recent published articles' do
    popular = Article.popular(limit: 5)

    assert_equal 5, popular.count
    assert popular.all?(&:published?), 'All articles should be published'
  end
end
