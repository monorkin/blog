# frozen_string_literal: true

require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "GET index renders the settings page" do
    get settings_path

    assert_response :success
  end

  test "GET index does not create a session" do
    get settings_path

    assert_response :success
    assert_nil session[:session_id]
  end
end
