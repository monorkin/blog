# frozen_string_literal: true

require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # Index

  test "GET index renders published articles" do
    get articles_path

    assert_response :success
    assert_select "li", minimum: 1
  end

  test "GET index does not show unpublished articles to guests" do
    article = articles(:misguided_mark)
    article.update!(published: false)

    get articles_path

    assert_response :success
    assert_no_match(/#{Regexp.escape(article.title)}/, response.body)
  end

  test "GET index shows unpublished articles to authenticated users" do
    login

    article = articles(:misguided_mark)
    article.update!(published: false)

    get articles_path

    assert_response :success
    assert_match(/#{Regexp.escape(article.title)}/, response.body)
  end

  test "GET index does not create a session" do
    get articles_path

    assert_response :success
    assert_nil session[:session_id]
  end

  test "GET index renders subsequent pages with page parameter" do
    get articles_path(page: 2)

    assert_response :success
  end

  # Show

  test "GET show renders a published article" do
    article = articles(:misguided_mark)

    get article_path(slug: article.to_param)

    assert_response :success
    assert_select "h1", text: article.title
  end

  test "GET show resolves article by slug suffix only" do
    article = articles(:misguided_mark)
    entry = article.entry

    get article_path(slug: "anything-#{entry.slug_id}")

    assert_response :success
    assert_select "h1", text: article.title
  end

  test "GET show returns not found for unknown slug" do
    get article_path(slug: "nonexistent-zzz999")

    assert_response :not_found
  end

  test "GET show does not create a session" do
    article = articles(:misguided_mark)

    get article_path(slug: article.to_param)

    assert_response :success
    assert_nil session[:session_id]
  end

  # New

  test "GET new requires authentication" do
    get new_article_path

    assert_response :unauthorized
  end

  test "GET new renders form when authenticated" do
    login

    get new_article_path

    assert_response :success
    assert_select "form"
  end

  # Create

  test "POST create requires authentication" do
    post articles_path, params: { article: { title: "Test", body: "Content" } }

    assert_response :unauthorized
  end

  test "POST create creates an article and redirects" do
    login

    assert_difference "Article.count", 1 do
      post articles_path, params: { article: { title: "New Article", body: "Some content", published: true, publish_at: 1.day.ago } }
    end

    article = Article.last
    assert_redirected_to article_path(slug: article.to_param)
  end

  test "POST create renders form on validation error" do
    login

    assert_no_difference "Article.count" do
      post articles_path, params: { article: { title: "", body: "" } }
    end

    assert_response :unprocessable_entity
  end

  # Edit

  test "GET edit requires authentication" do
    article = articles(:misguided_mark)

    get edit_article_path(slug: article.to_param)

    assert_response :unauthorized
  end

  test "GET edit renders form when authenticated" do
    login
    article = articles(:misguided_mark)

    get edit_article_path(slug: article.to_param)

    assert_response :success
    assert_select "form"
  end

  # Update

  test "PATCH update requires authentication" do
    article = articles(:misguided_mark)

    patch article_path(slug: article.to_param), params: { article: { title: "Updated" } }

    assert_response :unauthorized
  end

  test "PATCH update updates the article and redirects" do
    login
    article = articles(:misguided_mark)

    patch article_path(slug: article.to_param), params: { article: { title: "Updated Title" } }

    assert_redirected_to article_path(slug: article.reload.to_param)
    assert_equal "Updated Title", article.title
  end

  test "PATCH update renders form on validation error" do
    login
    article = articles(:misguided_mark)

    patch article_path(slug: article.to_param), params: { article: { title: "" } }

    assert_response :unprocessable_entity
  end

  # Destroy

  test "DELETE destroy requires authentication" do
    article = articles(:misguided_mark)

    delete article_path(slug: article.to_param)

    assert_response :unauthorized
  end

  test "DELETE destroy deletes the article and redirects" do
    login
    article = articles(:misguided_mark)

    assert_difference "Article.count", -1 do
      delete article_path(slug: article.to_param)
    end

    assert_redirected_to articles_path
  end

  private
    def login
      post login_path, params: { login: { username: "alice", password: "hunter2" } }
    end
end
