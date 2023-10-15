# frozen_string_literal: true

module ApplicationHelper
  PROFILE_IMAGE_SRCSET = {
    "portrait/small.jpg" => "512w",
    "portrait/medium.jpg" => "1024w",
    "portrait/large.jpg" => "2048w",
  }.freeze

  def profile_image_tag(**options)
    version = options.delete(:version) || :medium
    default_image_path = "portrait/#{version}.jpg"

    options[:srcset] = PROFILE_IMAGE_SRCSET if !options.key?(:srcset)
    options.delete(:srcset) if options[:srcset].blank?
    options[:alt] ||= "Stanko K.R."
    options[:class] ||= ""
    options[:class] += " grayscale "

    image_tag(default_image_path, **options)
  end
end
