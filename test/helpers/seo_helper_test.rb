# frozen_string_literal: true

require 'test_helper'

class SEOHelperTest < ActionView::TestCase
  include SEOHelper

  test 'seo_meta_tags returns array of meta tags' do
    tags = seo_meta_tags(
      title: 'Test Page',
      description: 'This is a test page',
      url: 'https://example.com/test'
    )

    assert_instance_of Array, tags
    assert tags.size > 0
  end

  test 'seo_meta_tags includes title in format "Title | Stanko K.R."' do
    tags = seo_meta_tags(
      title: 'Test Page',
      description: 'Description',
      url: 'https://example.com'
    )

    # Find Twitter title tag
    twitter_title = tags.find { |tag| tag.include?('twitter:title') }
    assert_match(/Test Page \| Stanko K\.R\./, twitter_title)

    # Find OG title tag
    og_title = tags.find { |tag| tag.include?('og:title') }
    assert_match(/Test Page \| Stanko K\.R\./, og_title)
  end

  test 'seo_meta_tags includes description' do
    description = 'This is a test description'
    tags = seo_meta_tags(
      title: 'Test',
      description: description,
      url: 'https://example.com'
    )

    # Should include meta description
    meta_desc = tags.find { |tag| tag.include?('name="description"') }
    assert_match(/#{description}/, meta_desc)

    # Should include Twitter description
    twitter_desc = tags.find { |tag| tag.include?('twitter:description') }
    assert_match(/#{description}/, twitter_desc)

    # Should include OG description
    og_desc = tags.find { |tag| tag.include?('og:description') }
    assert_match(/#{description}/, og_desc)
  end

  test 'seo_meta_tags includes canonical link' do
    url = 'https://example.com/test'
    tags = seo_meta_tags(
      title: 'Test',
      description: 'Description',
      url: url
    )

    canonical = tags.find { |tag| tag.include?('rel="canonical"') }
    assert_not_nil canonical
    assert_match(/href="#{Regexp.escape(url)}"/, canonical)
  end

  test 'seo_meta_tags includes Twitter card tags' do
    tags = seo_meta_tags(
      title: 'Test',
      description: 'Description',
      url: 'https://example.com'
    )

    # Should have Twitter card type
    assert(tags.any? { |tag| tag.include?('twitter:card') && tag.include?('summary') })

    # Should have Twitter creator
    assert(tags.any? { |tag| tag.include?('twitter:creator') && tag.include?('@monorkin') })
  end

  test 'seo_meta_tags includes Open Graph tags' do
    tags = seo_meta_tags(
      title: 'Test',
      description: 'Description',
      url: 'https://example.com',
      type: 'article'
    )

    # Should have OG type
    assert(tags.any? { |tag| tag.include?('og:type') && tag.include?('article') })

    # Should have OG locale
    assert(tags.any? { |tag| tag.include?('og:locale') && tag.include?('en_US') })

    # Should have OG URL
    assert(tags.any? { |tag| tag.include?('og:url') })
  end

  test 'seo_meta_tags uses default image when not provided' do
    tags = seo_meta_tags(
      title: 'Test',
      description: 'Description',
      url: 'https://example.com'
    )

    # Should include default portrait image
    twitter_image = tags.find { |tag| tag.include?('twitter:image') }
    assert_match(%r{portrait/medium\.jpg}, twitter_image)

    og_image = tags.find { |tag| tag.include?('og:image') }
    assert_match(%r{portrait/medium\.jpg}, og_image)
  end

  test 'seo_meta_tags uses custom image when provided' do
    custom_image = 'https://example.com/custom.jpg'
    tags = seo_meta_tags(
      title: 'Test',
      description: 'Description',
      url: 'https://example.com',
      image: custom_image
    )

    twitter_image = tags.find { |tag| tag.include?('twitter:image') }
    assert_match(/#{Regexp.escape(custom_image)}/, twitter_image)

    og_image = tags.find { |tag| tag.include?('og:image') }
    assert_match(/#{Regexp.escape(custom_image)}/, og_image)
  end

  test 'seo_meta_tags uses custom type when provided' do
    tags = seo_meta_tags(
      title: 'Test',
      description: 'Description',
      url: 'https://example.com',
      type: 'article'
    )

    og_type = tags.find { |tag| tag.include?('og:type') }
    assert_match(/article/, og_type)
  end

  test 'seo_meta_tags defaults to website type' do
    tags = seo_meta_tags(
      title: 'Test',
      description: 'Description',
      url: 'https://example.com'
    )

    og_type = tags.find { |tag| tag.include?('og:type') }
    assert_match(/website/, og_type)
  end

  test 'noindex_meta_tag returns robots noindex tag' do
    tag = noindex_meta_tag

    assert_match(/name="robots"/, tag)
    assert_match(/content="noindex, nofollow"/, tag)
  end
end
