# frozen_string_literal: true

require 'application_system_test_case'

class AboutTest < ApplicationSystemTestCase
  test 'should pass all accessibility criteria' do
    visit root_url

    assert_accessible(page)
  end
end
