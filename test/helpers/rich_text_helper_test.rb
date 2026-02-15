# frozen_string_literal: true

require "test_helper"

class RichTextHelperTest < ActionView::TestCase
  test "#highlight_code_blocks_rich_text_transform highlights code with known language" do
    html = '<pre language="ruby"><code data-language="ruby">puts "hello"</code></pre>'
    document = Nokogiri.HTML(html)

    result = highlight_code_blocks_rich_text_transform(document)

    assert_match(/highlight/, result.to_s)
  end

  test "#highlight_code_blocks_rich_text_transform skips code without language" do
    html = '<pre><code>plain text</code></pre>'
    document = Nokogiri.HTML(html)

    result = highlight_code_blocks_rich_text_transform(document)

    assert_no_match(/highlight/, result.to_s)
    assert_match(/plain text/, result.to_s)
  end

  test "#highlight_code_blocks_rich_text_transform skips unknown languages" do
    html = '<pre language="totally_fake_language_xyz"><code>some code</code></pre>'
    document = Nokogiri.HTML(html)

    result = highlight_code_blocks_rich_text_transform(document)

    assert_no_match(/highlight/, result.to_s)
  end

  test "#highlight_code_blocks_rich_text_transform converts br tags to newlines" do
    html = '<pre language="ruby"><code data-language="ruby">line1<br>line2</code></pre>'
    document = Nokogiri.HTML(html)

    result = highlight_code_blocks_rich_text_transform(document)
    text = Nokogiri.HTML(result.to_s).text

    assert_match(/line1/, text)
    assert_match(/line2/, text)
  end
end
