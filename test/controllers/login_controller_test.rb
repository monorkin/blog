# frozen_string_literal: true

require "test_helper"

class LoginControllerTest < ActionDispatch::IntegrationTest
  test "GET new renders the login form" do
    get login_path

    assert_response :success
    assert_select "form"
  end

  test "POST create logs in with valid credentials" do
    post login_path, params: { login: { username: "alice", password: "hunter2" } }

    assert_redirected_to root_path
    assert_equal users(:alice).id, session[:user_id]
  end

  test "POST create renders form with invalid credentials" do
    post login_path, params: { login: { username: "alice", password: "wrong" } }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "POST create renders form with unknown username" do
    post login_path, params: { login: { username: "nobody", password: "hunter2" } }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "DELETE destroy logs out and redirects" do
    post login_path, params: { login: { username: "alice", password: "hunter2" } }
    assert_equal users(:alice).id, session[:user_id]

    delete login_path

    assert_redirected_to root_path
    assert_nil session[:user_id]
  end
end
