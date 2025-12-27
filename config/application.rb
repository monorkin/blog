# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative './version'

module Blog
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.after_initialize do
      ActionText::ContentHelper.allowed_attributes = [
        'style',
        'controls',
        'autoplay',
        'playsinline',
        'poster',
        'loop',
        'muted',
        'loading',
        'data-controller',
        'data-action',
        'language',
        *ActionText::ContentHelper.sanitizer.class.allowed_attributes,
        *ActionText::Attachment::ATTRIBUTES
      ]

      ActionText::ContentHelper.allowed_tags = [
        'video',
        'source',
        'table',
        'thead',
        'tbody',
        'tr',
        'th',
        'td',
        *ActionText::ContentHelper.sanitizer.class.allowed_tags,
        ActionText::Attachment.tag_name,
        'figure',
        'figcaption'
      ]
    end
  end
end
