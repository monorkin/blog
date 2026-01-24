# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Rails.app.creds.option(:sentry, :dsn)
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for tracing.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = Rails.app.creds.option(:sentry, :traces_sample_rate, default: 0.1)

  # Set profiles_sample_rate to profile 100%
  # of sampled transactions.
  # We recommend adjusting this value in production.
  config.profiles_sample_rate = Rails.app.creds.option(:sentry, :profiles_sample_rate, default: 0.1)

  # Filter sensitive data
  config.send_default_pii = false

  # Set the environment
  config.environment = Rails.env

  # Track releases using the application version (Git revision)
  config.release = Rails.application.config.version

  # Enable performance monitoring
  config.enabled_environments = %w[production]
end
