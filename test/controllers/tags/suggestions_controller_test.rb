# frozen_string_literal: true

require "test_helper"

module Tags
  class SuggestionsControllerTest < ActionDispatch::IntegrationTest
    test "GET index requires authentication" do
      get suggestions_path

      assert_response :unauthorized
    end

    test "GET index returns matching tag suggestions" do
      login

      get suggestions_path, params: { query: "rub" }

      assert_response :success
      assert_equal "application/json", response.media_type

      suggestions = JSON.parse(response.body)
      assert_includes suggestions, "ruby"
    end

    test "GET index returns empty array for no matches" do
      login

      get suggestions_path, params: { query: "zzzznonexistent" }

      assert_response :success
      assert_equal [], JSON.parse(response.body)
    end

    private
      def login
        post login_path, params: { login: { username: "alice", password: "hunter2" } }
      end
  end
end
