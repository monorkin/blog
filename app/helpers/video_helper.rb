module VideoHelper
  def video_embed_for(url, **options)
    if url.include?("youtube")
      youtube_video_embed_for(url, **options)
    else
      html_video_embed_for(url, **options)
    end
  end

  def youtube_video_embed_for(url, **options)
    video_id = url.scan(/v=([^&]+)/).flatten.first

    content_tag(:iframe, nil, src: "https://www.youtube.com/embed/#{video_id}",
      frameborder: 0, allowfullscreen: true, **options)
  end

  def html_video_embed_for(url, **options)
    content_tag(:video, nil, src: url, controls: true, **options)
  end
end
