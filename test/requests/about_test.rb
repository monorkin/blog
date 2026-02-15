# frozen_string_literal: true

require "test_helper"

class AboutRequestTest < ActionDispatch::IntegrationTest
  test "/ renders successfully" do
    get root_path

    assert_response :success
  end

  test "/ includes SEO meta tags" do
    get root_path

    assert_select 'meta[name="description"]', 1
    assert_select 'link[rel="canonical"]', 1
    assert_select 'meta[property="og:title"]', 1
    assert_select 'meta[property="og:description"]', 1
    assert_select 'meta[property="og:image"]', 1
    assert_select 'meta[name="twitter:title"]', 1
    assert_select 'meta[name="twitter:image"]', 1
  end

  test "/ includes default SEO image when no image provided" do
    get root_path

    assert_select 'meta[property="og:image"]' do |elements|
      assert_match(/default_seo_image/, elements.first["content"])
    end
  end
end
