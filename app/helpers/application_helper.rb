# frozen_string_literal: true

module ApplicationHelper
  PROFILE_IMAGE_SRCSET = {
    "portrait/small.jpg" => "512w",
    "portrait/medium.jpg" => "1024w",
    "portrait/large.jpg" => "2048w"
  }.freeze

  def profile_image_tag(**options)
    version = options.delete(:version) || :medium
    default_image_path = "portrait/#{version}.jpg"

    options[:srcset] = PROFILE_IMAGE_SRCSET unless options.key?(:srcset)
    options.delete(:srcset) if options[:srcset].blank?
    options[:alt] ||= "Stanko K.R."
    options[:class] ||= ""
    options[:class] += " profile-img "

    image_tag(default_image_path, **options)
  end

  def validation_errors(form)
    content_tag(:ul, class: "form__errors") do
      form.object.errors.full_messages.each do |message|
        concat(content_tag(:li, message))
      end
    end
  end
end
