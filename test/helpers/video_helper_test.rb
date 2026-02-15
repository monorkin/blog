# frozen_string_literal: true

require "test_helper"

class VideoHelperTest < ActionView::TestCase
  test "#video_embed_for renders YouTube iframe for YouTube URLs" do
    result = video_embed_for("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    assert_match(/<iframe/, result)
    assert_match(/youtube\.com\/embed\/dQw4w9WgXcQ/, result)
  end

  test "#video_embed_for renders HTML video tag for non-YouTube URLs" do
    result = video_embed_for("https://example.com/video.mp4")

    assert_match(/<video/, result)
    assert_match(/controls/, result)
    assert_match(/example\.com\/video\.mp4/, result)
  end

  test "#youtube_video_embed_for extracts video ID from URL" do
    result = youtube_video_embed_for("https://www.youtube.com/watch?v=abc123&t=10")

    assert_match(/youtube\.com\/embed\/abc123/, result)
  end

  test "#youtube_video_embed_for passes HTML options" do
    result = youtube_video_embed_for("https://www.youtube.com/watch?v=abc123", class: "aspect-video")

    assert_match(/aspect-video/, result)
  end

  test "#html_video_embed_for renders a video element with controls" do
    result = html_video_embed_for("https://example.com/talk.mp4")

    assert_match(/<video/, result)
    assert_match(/controls/, result)
    assert_match(/talk\.mp4/, result)
  end

  test "#html_video_embed_for passes HTML options" do
    result = html_video_embed_for("https://example.com/talk.mp4", class: "rounded")

    assert_match(/rounded/, result)
  end
end
