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

  def validation_errors(form)
    content_tag(:ul, class: "text-red-900 p-4 rounded-lg border border-red-700 bg-red-300") do
      form.object.errors.full_messages.each do |message|
        concat(content_tag(:li, message))
      end
    end
  end

  def primary_button_classes(extra_classes = nil)
    "rounded text-white p-2 cursor-pointer bg-indigo-500 hover:bg-indigo-700 dark:bg-yellow-500 dark:text-yellow-900 dark:hover:bg-yellow-400 #{extra_classes}".strip
  end
end
