# frozen_string_literal: true

require "test_helper"

module Articles
  class LinkPreviewsControllerTest < ActionDispatch::IntegrationTest
    test "GET show returns not found when no link preview exists" do
      article = articles(:misguided_mark)
      encoded_url = Base64.urlsafe_encode64("https://example.com")

      get article_link_preview_path(article_slug: article.to_param, base64_encoded_url: encoded_url)

      assert_response :not_found
    end

    test "GET show returns not found for invalid base64" do
      article = articles(:misguided_mark)

      get article_link_preview_path(article_slug: article.to_param, base64_encoded_url: "!!invalid!!")

      assert_response :not_found
    end

    test "GET show renders a fetched link preview" do
      article = articles(:misguided_mark)
      url = "https://example.com/test"
      link_preview = article.link_previews.create!(url: url, title: "Example", description: "A test link preview")

      encoded_url = Base64.urlsafe_encode64(url)

      get article_link_preview_path(article_slug: article.to_param, base64_encoded_url: encoded_url)

      assert_response :success
    end

    test "HEAD show returns ok for a fetched link preview" do
      article = articles(:misguided_mark)
      url = "https://example.com/head-test"
      article.link_previews.create!(url: url, title: "Example", description: "A test")

      encoded_url = Base64.urlsafe_encode64(url)

      head article_link_preview_path(article_slug: article.to_param, base64_encoded_url: encoded_url)

      assert_response :ok
    end

    test "GET show returns not found for unfetched link preview" do
      article = articles(:misguided_mark)
      url = "https://example.com/unfetched"
      article.link_previews.create!(url: url, title: nil, description: nil)

      encoded_url = Base64.urlsafe_encode64(url)

      get article_link_preview_path(article_slug: article.to_param, base64_encoded_url: encoded_url)

      assert_response :not_found
    end
  end
end
