# frozen_string_literal: true

require 'image_processing/vips'

class Article
  class AttachmentUploader < Shrine
    add_metadata do |io, _context|
      if Marcel::MimeType.for(io).starts_with?('video')
        movie = Shrine.with_file(io) { |file| FFMPEG::Movie.new(file.path) }

        {
          'bitrate' => movie.bitrate,
          'duration' => movie.duration,
          'frame_rate' => movie.frame_rate,
          'height' => movie.height,
          'width' => movie.width
        }
      else
        {}
      end
    rescue Errno::ENOENT
      {}
    end

    add_metadata :md5_digest do |io|
      calculate_signature(io, :md5)
    end

    add_metadata :exif do |io, _context|
      Shrine.with_file(io) do |file|
        Exiftool.new(file.path).to_hash
      rescue Exiftool::NoSuchFile
        {}
      end
    end

    Attacher.derivatives do |original|
      case Marcel::MimeType.for(original)
      when 'image/gif' then process_gif(original)
      when %r{^image/.+$} then process_image(original)
      when %r{^video/.+$} then process_video(original)
      else {}
      end
    end

    class Attacher
      def process_gif(_original)
        {}
      end

      def process_image(original)
        image = ImageProcessing::Vips.source(original)

        {
          large: image.resize_to_limit!(1024, 1024),
          medium: image.resize_to_limit!(512, 512),
          small: image.resize_to_limit!(256, 256),
          thumbnail: image.resize_to_limit!(32, 32)
        }
      end

      def process_video(original)
        screenshot = Tempfile.new ['screenshot', '.jpg']
        mp4 = Tempfile.new ['transcode', '.mp4']
        webm = Tempfile.new ['transcode', '.webm']

        movie = FFMPEG::Movie.new(original.path)
        movie.screenshot(screenshot.path)
        screenshot_image = ImageProcessing::Vips.source(screenshot)
        movie.transcode(mp4.path)
        movie.transcode(webm.path)

        {
          preview: screenshot,
          large_preview: screenshot_image.resize_to_limit!(1024, 1024),
          medium_preview: screenshot_image.resize_to_limit!(512, 512),
          small_preview: screenshot_image.resize_to_limit!(256, 256),
          mp4: mp4,
          webm: webm
        }
      end
    end
  end
end
