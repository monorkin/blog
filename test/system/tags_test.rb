# frozen_string_literal: true

require 'application_system_test_case'

class TagsTest < ApplicationSystemTestCase
  fixtures :articles, :tags, 'tag/taggings', 'action_text/rich_texts'

  test 'visiting a tag page shows tagged articles' do
    tag = tags(:ruby)
    article = articles(:vanilla_rails_view_components_with_partials)

    visit tag_path(tag)

    # Should show the tag name as heading
    assert_selector 'h1', text: "##{tag.name}"

    # Should show the tagged article
    assert_text article.title
  end

  test 'clicking a tag bubble navigates to tag page' do
    article = articles(:vanilla_rails_view_components_with_partials)
    tag = tags(:ruby)

    visit article_path(article)

    # Find and click the tag bubble
    within 'article' do
      click_link "##{tag.name}"
    end

    # Should be on the tag page
    assert_current_path tag_path(tag)
    assert_selector 'h1', text: "##{tag.name}"
  end

  test 'tag page has pagination for many articles' do
    tag = tags(:ruby)

    # Create many articles with the tag
    15.times do |i|
      Article.create!(
        title: "Test Article #{i}",
        content: ActionText::Content.new("Content #{i}"),
        published: true,
        tags: 'ruby',
        publish_at: i.days.ago
      )
    end

    visit tag_path(tag)

    # Should have pagination link
    assert_selector 'a', text: /Older articles/i, count: 1
  end

  test 'tag page only shows published articles' do
    tag = tags(:people)

    # Create unpublished article with tag
    Article.create!(
      title: 'Unpublished Test Article',
      content: ActionText::Content.new('Content'),
      published: false,
      tags: 'people'
    )

    visit tag_path(tag)

    # Should not show unpublished article
    assert_no_text 'Unpublished Test Article'

    # Should show published articles
    assert_text articles(:misguided_mark).title
  end

  test 'tag page shows empty state when no articles' do
    # Create a new tag with no articles
    new_tag = Tag.create!(name: 'empty-tag')

    visit tag_path(new_tag)

    assert_selector 'h1', text: "##{new_tag.name}"
    assert_text 'No articles found with this tag'
  end

  test 'tag page passes accessibility criteria' do
    tag = tags(:ruby)

    visit tag_path(tag)

    assert_accessible(page)
  end

  test 'tag page with pagination passes accessibility criteria' do
    tag = tags(:ruby)

    # Create enough articles to trigger pagination
    15.times do |i|
      Article.create!(
        title: "Accessible Article #{i}",
        content: ActionText::Content.new("Content #{i}"),
        published: true,
        tags: 'ruby',
        publish_at: i.days.ago
      )
    end

    visit tag_path(tag)

    assert_accessible(page)
  end

  test 'tag page has proper SEO meta tags' do
    tag = tags(:ruby)

    visit tag_path(tag)

    # Check for canonical tag
    assert_selector "link[rel='canonical'][href='#{tag_url(tag)}']", visible: false

    # Check for description meta tag
    assert_selector "meta[name='description']", visible: false

    # Check for Open Graph tags
    assert_selector "meta[property='og:title']", visible: false
    assert_selector "meta[property='og:description']", visible: false

    # Check for Twitter card tags
    assert_selector "meta[name='twitter:card']", visible: false
    assert_selector "meta[name='twitter:title']", visible: false
  end
end
