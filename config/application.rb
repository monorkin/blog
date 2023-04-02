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
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.after_initialize do
      ActionText::ContentHelper.allowed_attributes.add "style"
      ActionText::ContentHelper.allowed_attributes.add "controls"
      ActionText::ContentHelper.allowed_attributes.add "autoplay"
      ActionText::ContentHelper.allowed_attributes.add "poster"
      ActionText::ContentHelper.allowed_attributes.add "loop"
      ActionText::ContentHelper.allowed_attributes.add "muted"

      ActionText::ContentHelper.allowed_tags.add "video"
      ActionText::ContentHelper.allowed_tags.add "source"
      ActionText::ContentHelper.allowed_tags.add "table"
      ActionText::ContentHelper.allowed_tags.add "thead"
      ActionText::ContentHelper.allowed_tags.add "tbody"
      ActionText::ContentHelper.allowed_tags.add "tr"
      ActionText::ContentHelper.allowed_tags.add "th"
      ActionText::ContentHelper.allowed_tags.add "td"
    end

    # Store Resque configuration
    config.resque = config_for(:resque)

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
    config.active_job.queue_adapter = :resque

    uri = URI(config.security[:default_host] || "http://localhost")
    routes.default_url_options[:host] = uri.host
    routes.default_url_options[:protocol] = uri.scheme
    routes.default_url_options[:port] = uri.port
  end
end
