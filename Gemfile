# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.3"

gem "httpx"
gem "lexxy", "~> 0.7.4.beta"
gem "aws-sdk-s3", "~> 1.14"
gem "bcrypt", "~> 3.1.7"
gem "bootsnap"
gem "exiftool"
gem "fastimage"
gem "geared_pagination"
gem "image_processing", "~> 1.8"
gem "importmap-rails"
gem "sqlite3"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", github: "rails/rails", branch: "main"
gem "solid_queue"
gem "solid_cache"
gem "solid_cable"
gem "mission_control-jobs"
gem "rouge"
gem "rss"
gem "sentry-rails"
gem "sentry-ruby"
gem "stimulus-rails"
gem "streamio-ffmpeg"
gem "thruster"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "faker"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "hotwire-spark"
  gem "kamal", ">= 2"
  gem "listen"
  gem "memory_profiler"
  gem "rack-mini-profiler", require: %w[enable_rails_patches rack-mini-profiler]
  gem "stackprof"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
end
