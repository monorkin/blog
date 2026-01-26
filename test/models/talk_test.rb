# frozen_string_literal: true

require "test_helper"

class TalkTest < ActiveSupport::TestCase
  fixtures :talks, :entries, "action_text/rich_texts"

  test ".from_slug via Entry" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)
    entry = talk.entry

    assert_equal entry, Entry.from_slug!(entry.to_param), "Can resolve an Entry from its slug"
    assert_equal talk, Entry.from_slug!(entry.to_param).entryable, "Can resolve a Talk via Entry"

    assert_raises(ActiveRecord::RecordNotFound) do
      Entry.from_slug!("does-not-exist")
    end
  end

  test "#to_param delegates to entry" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    assert_equal talk.entry.to_param, talk.to_param
  end

  test "#excerpt returns truncated plain text from description" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    # Create a description with content
    talk.description = ActionText::Content.new("This is a talk about WebSockets and when you should use them. " * 10)

    excerpt = talk.excerpt(length: 100)

    assert_not_nil excerpt
    assert excerpt.length <= 100
    assert excerpt.ends_with?("...")
  end

  test "#excerpt returns nil when description is blank" do
    talk = talks(:filler_talk_0)

    assert_nil talk.description.body.to_s.presence
    assert_nil talk.excerpt
  end

  test "#content returns ActionText::Content from description" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)
    talk.description = ActionText::Content.new("<p>This is <strong>formatted</strong> text</p>")

    content = talk.content

    assert_kind_of ActionText::Content, content
  end
end
