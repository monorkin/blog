# frozen_string_literal: true

require 'application_system_test_case'

class LoginTest < ApplicationSystemTestCase
  fixtures :users

  test "allows me to login with valid information" do
    visit login_path

    fill_in "Username", with: users(:alice).username
    fill_in "Password", with: "hunter2"
    click_button "Login"

    assert_current_path root_path
    assert_text "Logout"
  end

  test "does not allow me to login if the username doesn't exist" do
    visit login_path

    # Check that the lockout doesn't apply if the username doesn't exist.
    (User::MAX_LOGIN_ATTEMPTS + 1).times do
      fill_in "Username", with: "non-existent"
      fill_in "Password", with: "hunter2"
      click_button "Login"

      assert_current_path login_path
      assert_text "Doesn't match any user"
    end
  end

  test "does not allow me to login if the password is incorrect and locks me out if I fail too many times" do
    User::MAX_LOGIN_ATTEMPTS.times do
      visit login_path

      fill_in "Username", with: users(:alice).username
      fill_in "Password", with: "incorrect-password"
      click_button "Login"

      assert_current_path login_path
      assert_text "Password is invalid"
    end

    # Check that the lockout actually locks me out.
    fill_in "Username", with: users(:alice).username
    fill_in "Password", with: "hunter2"
    click_button "Login"

    assert_current_path login_path
    assert_text "can't login because it's locked out due to too many failed login attempts"
  end

  test "the lockout resets after a successful login" do
    2.times do
      visit login_path

      (User::MAX_LOGIN_ATTEMPTS - 1).times do
        fill_in "Username", with: users(:alice).username
        fill_in "Password", with: "incorrect-password"
        click_button "Login"

        assert_current_path login_path
        assert_text "Password is invalid"
      end

      fill_in "Username", with: users(:alice).username
      fill_in "Password", with: "hunter2"
      click_button "Login"

      assert_current_path root_path
      assert_text "Logout"

      click_button "Logout"
    end
  end
end
