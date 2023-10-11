# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.2"

gem "appsignal"
gem "async-http"
gem "aws-sdk-s3", "~> 1.14"
gem "bcrypt", "~> 3.1.7"
gem "bootsnap"
gem "exiftool"
gem "fastimage"
gem "geared_pagination"
gem "hiredis"
gem "image_processing", "~> 1.8"
gem "importmap-rails"
gem "inline_svg"
gem "kredis", "~> 1.2"
gem "pg", ">= 0.18", "< 2.0"
gem "propshaft"
gem "puma", ">= 5.0"
gem "pundit", "~> 2.1.0"
gem "rails", "~> 7.1"
gem "redis", "~> 4.0"
gem "rss"
gem "sitemap_generator"
gem "slim"
gem "stimulus-rails"
gem "streamio-ffmpeg"
gem "tailwindcss-rails"
gem "turbo-rails"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "listen"
  gem "memory_profiler"
  gem "kamal"
  gem "rack-mini-profiler", require: %w[enable_rails_patches rack-mini-profiler]
  gem "stackprof"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "axe-core-selenium"
  gem "capybara", ">= 2.15"
  gem "faker"
  gem "selenium-webdriver"
  gem "webdrivers"
end

gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
