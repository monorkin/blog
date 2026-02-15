# frozen_string_literal: true

require "test_helper"

class LoginTest < ActiveSupport::TestCase
  test "#login succeeds with valid credentials" do
    login = Login.new(username: "alice", password: "hunter2")

    assert login.login, "Should return true with valid credentials"
    assert_not_nil login.user
  end

  test "#login fails with wrong password" do
    login = Login.new(username: "alice", password: "wrong")

    assert_not login.login
    assert login.errors[:password].any?, "Should have password error"
  end

  test "#login fails with unknown username" do
    login = Login.new(username: "nobody", password: "hunter2")

    assert_not login.login
    assert login.errors[:username].any?, "Should have username error"
  end

  test "#login increments login attempt count on failure" do
    user = users(:alice)
    user.unlock!
    original_count = user.reload.login_attempt_count

    Login.new(username: "alice", password: "wrong").login

    assert_equal original_count + 1, user.reload.login_attempt_count,
                 "Should increment login attempt count"
  end

  test "#login resets attempts on success" do
    user = users(:alice)
    user.update_columns(login_attempt_count: 2)

    Login.new(username: "alice", password: "hunter2").login

    assert_equal 0, user.reload.login_attempt_count,
                 "Should reset login attempt count on success"
  end

  test "#login fails when user is locked" do
    user = users(:alice)
    user.update_columns(login_attempt_count: User::MAX_LOGIN_ATTEMPTS, login_attempted_at: Time.current)

    login = Login.new(username: "alice", password: "hunter2")

    assert_not login.login
    assert login.errors[:username].any?, "Should have locked error"
  end

  test "#login resets attempts when last attempt was over 30 minutes ago" do
    user = users(:alice)
    user.update_columns(login_attempt_count: 2, login_attempted_at: 31.minutes.ago)

    login = Login.new(username: "alice", password: "hunter2")

    assert login.login, "Should succeed and reset old attempts"
    assert_equal 0, user.reload.login_attempt_count
  end
end
