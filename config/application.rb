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

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.after_initialize do
      ActionText::ContentHelper.allowed_attributes = [
        "style",
        "controls",
        "autoplay",
        "playsinline",
        "poster",
        "loop",
        "muted",
        "loading",
        "data-controller",
        "data-action",
        "language",
        *ActionText::ContentHelper.sanitizer.class.allowed_attributes,
        *ActionText::Attachment::ATTRIBUTES
      ]

      ActionText::ContentHelper.allowed_tags = [
        "video",
        "source",
        "table",
        "thead",
        "tbody",
        "tr",
        "th",
        "td",
        *ActionText::ContentHelper.sanitizer.class.allowed_tags,
        ActionText::Attachment.tag_name,
        "figure",
        "figcaption"
      ]
    end

    # Store security configurations
    config.security = config_for(:security)

    # Store file storage configurations
    config.active_storage.service = :local

    # Allowed application hosts
    config.hosts.push(*config.security[:allowed_hosts])
    config.hosts << IPAddr.new('0.0.0.0/0')
    config.hosts << IPAddr.new('::/0')

    # Use custom error pages
    config.exceptions_app = routes

    # Configure ActiveJob queue adapter
    # config.active_job.queue_adapter = :resque

    if !Rails.env.test?
      uri = URI(config.security[:default_host] || "http://localhost")
      routes.default_url_options[:host] = uri.host
      routes.default_url_options[:protocol] = uri.scheme
      routes.default_url_options[:port] = uri.port
    end

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
