# frozen_string_literal: true

if defined?(Rack::MiniProfiler)
  Rack::MiniProfiler.config.tap do |config|
    config.position = "bottom-right"
    config.enable_hotwire_turbo_drive_support = true
    config.enable_advanced_debugging_tools = Rails.env.development?
    config.pre_authorize_cb = ->(_env) { !Rails.env.test? && Rails.root.join("tmp/profiling-dev.txt").exist? }
    config.skip_paths += [%r{^/?uploads/.*$}i]
  end
end
