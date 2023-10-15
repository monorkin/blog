# frozen_string_literal: true

if defined?(Rack::MiniProfiler)
  Rack::MiniProfiler.config.position = "bottom-right"

  Rack::MiniProfiler.config.disable_caching =
    !File.exist?(Rails.root.join("tmp/dev-disable-rack-mini-profiler-etag-stripping.txt"))

  Rack::MiniProfiler.config.enable_advanced_debugging_tools = Rails.env.development?
  # Rack::MiniProfiler.config.enable_hotwire_turbo_drive_support = true

  Rack::MiniProfiler.config.skip_paths += [
    %r{^/?uploads/.*$}i
  ]
end
