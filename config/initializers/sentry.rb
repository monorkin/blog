# frozen_string_literal: true

credentials = Rails.application.credentials[:sentry]

if credentials.present?
  Sentry.init do |config|
    config.dsn = credentials.fetch(:dsn)
    config.breadcrumbs_logger = %i[active_support_logger http_logger]

    # Set traces_sample_rate to 1.0 to capture 100% of transactions for performance
    # monitoring. We recommend adjusting this value in production
    config.traces_sample_rate = 0.5
  end
end
