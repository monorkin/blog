# frozen_string_literal: true

require 'test_helper'

class Article::ImportTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  test '#save imports the blog post from the given bundle archive' do
    bundle = fixture_file_upload('sample_blog_post/sample_blog_post_archive.zip')
    import = Article::Import.new(bundle: bundle)

    assert_equal(import.valid?, true)
    assert_equal(import.save, true)

    assert_equal(import.article.id, 'deadbeef')
    assert_equal(import.article.title, 'Sample Blog post')
    assert_equal(import.article.slug, 'sample-blog-post-deadbeef')
    assert_equal(import.article.published, true)
    assert_equal(
      import.article.attachments.map(&:original_path).sort,
      ['./assets/image.jpeg', './assets/image.jpeg', './assets/video.mp4']
    )
    assert_equal(import.article.primary_image.original_path, './assets/image.jpeg')
  end
end
