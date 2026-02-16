# frozen_string_literal: true

require "application_system_test_case"

class AboutTest < ApplicationSystemTestCase
  test "visiting the about page" do
    visit root_url

    assert_selector "body"
  end
end
