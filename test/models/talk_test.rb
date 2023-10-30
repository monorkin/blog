require "test_helper"

class TalkTest < ActiveSupport::TestCase
  fixtures :talks, "action_text/rich_texts"

  test ".from_slug" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    assert_equal talk, Talk.from_slug!(talk.to_param), "Can resolve a Talk from it's slug"
    assert_equal talk, Talk.from_slug!(talk.id.to_s), "Can resolve a Talk from it's id"

    assert_raises(ActiveRecord::RecordNotFound) do
      Talk.from_slug!("does-not-exist")
    end
  end

  test "#to_param" do
    talk = talks(:do_you_really_need_websockets_webcamp_2018)

    assert_equal "do-you-really-need-websockets-webcamp-zagreb-2018-#{talk.id}", talk.to_param
  end
end
