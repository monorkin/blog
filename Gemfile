# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.1'

gem 'activejob-uniqueness'
gem 'active_link_to'
gem 'async-http'
gem 'aws-sdk-s3', '~> 1.14'
gem 'bcrypt', '~> 3.1.7'
gem 'bloomer'
gem 'connection_pool'
gem 'cssbundling-rails'
gem 'fastimage'
gem 'hiredis'
gem 'image_processing', '~> 1.8'
gem 'importmap-rails'
gem 'inline_svg'
gem 'kredis', '~> 1.2'
gem 'marcel', '~> 1'
gem 'nexter'
gem 'pg', '>= 0.18', '< 2.0'
gem 'pg_search'
gem 'propshaft'
gem 'puma', '~> 5.0.2'
gem 'pundit', '~> 2.1.0'
gem 'rails', '~> 7.0.3'
gem 'ransack'
gem 'redcarpet', '~> 3.5.0'
gem 'redis', '~> 4.0'
gem 'redlock'
gem 'resque'
gem 'rotp'
gem 'rouge', '~> 3.23.0'
gem 'rqrcode'
gem 'rubyzip'
gem 'sentry-rails'
gem 'sentry-resque'
gem 'sentry-ruby'
gem 'shrine', '~> 3.0'
gem 'sitemap_generator'
gem 'slim', '~> 4.1.0'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'toml'
gem 'turbo-rails'
gem 'warning', '~> 1.1.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry'
end

group :development do
  gem 'annotate'
  gem 'listen'
  gem 'memory_profiler'
  gem 'rack-mini-profiler', require: %w[enable_rails_patches rack-mini-profiler]
  gem 'stackprof'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'axe-core-selenium'
  gem 'capybara', '>= 2.15'
  gem 'faker'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
