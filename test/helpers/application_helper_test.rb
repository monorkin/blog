# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "#profile_image_tag renders an image tag with profile-img class" do
    result = profile_image_tag

    assert_match(/img/, result)
    assert_match(/profile-img/, result)
  end

  test "#profile_image_tag defaults to medium version" do
    result = profile_image_tag

    assert_match(/portrait\/medium\.jpg/, result)
  end

  test "#profile_image_tag accepts a version option" do
    result = profile_image_tag(version: :small)

    assert_match(/portrait\/small\.jpg/, result)
  end

  test "#profile_image_tag includes srcset by default" do
    result = profile_image_tag

    assert_match(/srcset/, result)
    assert_match(/512w/, result)
    assert_match(/1024w/, result)
    assert_match(/2048w/, result)
  end

  test "#profile_image_tag omits srcset when set to false" do
    result = profile_image_tag(srcset: false)

    assert_no_match(/srcset/, result)
  end

  test "#profile_image_tag has default alt text" do
    result = profile_image_tag

    assert_match(/Stanko K\.R\./, result)
  end

end
