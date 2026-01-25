# frozen_string_literal: true

class Entry::SEO::Image
  WIDTH = 512
  HEIGHT = 512
  SIZE = [ WIDTH, HEIGHT ].freeze

  delegate :url_helpers, to: "Rails.application.routes"

  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def attachment
    entry.cover_image
  end

  def present?
    attachment.present?
  end

  def variant
    if present?
      attachment.representation(resize_to_fill: SIZE, saver: { strip: true })
    end
  end

  def url
    variant&.processed&.url
  end

  def width
    SIZE[0] if present?
  end

  def height
    SIZE[1] if present?
  end

  def to_h
    if present?
      { url: url, width: width, height: height }
    else
      { url: default_url }
    end
  end

  private
    def default_url
      url_helpers.asset_url("default_seo_image.jpg")
    end
end
