# frozen_string_literal: true

require "test_helper"

class ArticlesAtomFeedTest < ActionDispatch::IntegrationTest
  fixtures :articles, "action_text/rich_texts"

  test "/articles/atom" do
    get atom_articles_path

    binding.irb
    parsed = Nokogiri::XML(response.body)

    assert_equal "http://www.w3.org/2005/Atom", parsed.root.namespace.href
  end
end
