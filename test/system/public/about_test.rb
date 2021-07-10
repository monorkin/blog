require 'application_system_test_case'

class Public::AboutTest < ApplicationSystemTestCase
  test 'should pass all accessibility criteria' do
    visit public_root_url

    assert_accessible(page)
  end
end
