# frozen_string_literal: true

require 'test_helper'

class TalkTest < ActiveSupport::TestCase
  fixtures :talks, 'action_text/rich_texts'

  test '.from_slug' do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    assert_equal talk, Talk.from_slug!(talk.to_param), "Can resolve a Talk from it's slug"
    assert_equal talk, Talk.from_slug!(talk.id.to_s), "Can resolve a Talk from it's id"

    assert_raises(ActiveRecord::RecordNotFound) do
      Talk.from_slug!('does-not-exist')
    end
  end

  test '#to_param' do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    assert_equal "do-you-really-need-websockets-webcamp-zagreb-2018-#{talk.id}", talk.to_param
  end

  test '#excerpt returns truncated plain text from description' do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    # Create a description with content
    talk.description = ActionText::Content.new('This is a talk about WebSockets and when you should use them. ' * 10)

    excerpt = talk.excerpt(length: 100)

    assert_not_nil excerpt
    assert excerpt.length <= 100
    assert excerpt.ends_with?('...')
  end

  test '#excerpt returns nil when description is blank' do
    talk = talks(:filler_talk_0)

    assert_nil talk.description.body.to_s.presence
    assert_nil talk.excerpt
  end

  test '#plain_text strips formatting from description' do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)
    talk.description = ActionText::Content.new('<p>This is <strong>formatted</strong> text</p>')

    plain = talk.plain_text

    assert_equal 'This is formatted text', plain
    assert_no_match(/<[^>]+>/, plain, 'Should not contain HTML tags')
  end

  test '#plain_text removes action text attachment markers' do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)
    talk.description = ActionText::Content.new('Text with [attachment] markers')

    plain = talk.plain_text

    assert_equal 'Text with  markers', plain
    assert_no_match(/\[[^\]]*\]/, plain, 'Should not contain attachment markers')
  end
end
