# frozen_string_literal: true

require "test_helper"

class ArticleHelperTest < ActionView::TestCase
  test "#article_list renders a ul with default classes" do
    articles_collection = [ articles(:misguided_mark) ]

    # Stub render for the collection
    self.define_singleton_method(:render) do |collection|
      "<li>article</li>".html_safe
    end

    result = article_list(articles_collection)

    assert_match(/<ul/, result)
    assert_match(/flex flex-col divide-y/, result)
  end

  test "#article_list accepts custom classes" do
    self.define_singleton_method(:render) do |collection|
      "".html_safe
    end

    result = article_list([], class: "custom-class")

    assert_match(/custom-class/, result)
  end
end
