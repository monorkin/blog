# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "#locked? returns false when login attempts are below threshold" do
    user = users(:alice)
    user.login_attempt_count = 0

    assert_not user.locked?
  end

  test "#locked? returns true when login attempts reach threshold" do
    user = users(:alice)
    user.login_attempt_count = User::MAX_LOGIN_ATTEMPTS

    assert user.locked?, "Should be locked at MAX_LOGIN_ATTEMPTS"
  end

  test "#unlock! resets login attempt count" do
    user = users(:alice)
    user.update_columns(login_attempt_count: User::MAX_LOGIN_ATTEMPTS)

    user.unlock!

    assert_equal 0, user.reload.login_attempt_count
    assert_not user.locked?
  end

  test "validates username presence" do
    user = User.new(username: "", password: "password")

    assert_not user.valid?
    assert user.errors[:username].any?, "Should have username error"
  end

  test "validates username uniqueness" do
    duplicate = User.new(username: users(:alice).username, password: "password")

    assert_not duplicate.valid?
    assert duplicate.errors[:username].any?, "Should have uniqueness error"
  end
end
