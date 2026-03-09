# frozen_string_literal: true

class Entry::SEO::Image
  WIDTH = 512
  HEIGHT = 512
  SIZE = [ WIDTH, HEIGHT ].freeze

  delegate :url_helpers, to: "Rails.application.routes"

  def self.default
    { url: ActionController::Base.helpers.asset_url("default_seo_image.jpg") }
  end

  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def attachment
    entry.cover_image
  end

  def present?
    variant.present?
  end

  def variant
    if attachment.present? && attachment.variable?
      attachment.variant(resize_to_fill: SIZE, saver: { strip: true })
    elsif attachment.present? && attachment.previewable?
      attachment.preview(resize_to_fill: SIZE, saver: { strip: true })
    end
  end

  def url
    url_helpers.url_for(variant) if present?
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
      self.class.default
    end
  end
end
