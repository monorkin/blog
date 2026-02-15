# frozen_string_literal: true

require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "GET index renders the search page" do
    get search_path

    assert_response :success
  end

  test "GET index renders results for a search term" do
    article = articles(:misguided_mark)

    get search_path, params: { search: { term: article.title.split.first } }

    assert_response :success
  end

  test "GET index renders with blank term" do
    get search_path, params: { search: { term: "" } }

    assert_response :success
  end

  test "GET index does not create a session" do
    get search_path

    assert_response :success
    assert_nil session[:session_id]
  end
end
