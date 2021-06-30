# frozen_string_literal: true

config = Rails.application.config_for(:resque)

Resque.logger = Rails.logger
Resque.redis = config.fetch(:redis_url)
Resque.inline = config.fetch(:inline, false)
