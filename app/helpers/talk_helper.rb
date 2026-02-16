# frozen_string_literal: true

module TalkHelper
  def talk_video_embed(talk)
    content_tag(:div, class: "talk__video-section") do
      video_url = talk.video_mirror_url.presence
      video_url = url_for(talk.video) if video_url.blank? && talk.video.attached?

      concat(video_embed_for(video_url, class: "talk__video")) if video_url.present?

      concat(content_tag(:div, class: "talk__video-links") do
        options = {
          class: "txt-link",
          target: "_blank",
          rel: "noopener noreferrer"
        }

        concat(link_to(t(".download_video"), url_for(talk.video), options)) if talk.video.attached?
        concat(link_to(t(".mirror"), talk.video_mirror_url, options)) if talk.video_mirror_url.present?
      end)
    end
  end
end
