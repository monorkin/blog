# frozen_string_literal: true

require "test_helper"

class AboutControllerTest < ActionDispatch::IntegrationTest
  test "GET show renders the about page" do
    get root_path

    assert_response :success
    assert_select "title", minimum: 1
  end

  test "GET show includes latest articles" do
    article = articles(:vanilla_rails_view_components_with_partials)

    get root_path

    assert_response :success
    assert_includes response.body, article.title
  end

  test "GET show does not create a session" do
    get root_path

    assert_response :success
    assert_nil session[:session_id]
  end

end
