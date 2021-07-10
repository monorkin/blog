# frozen_string_literal: true

require 'shrine'

def config
  Rails.application.credentials.fetch(:file_storage)
end

def storages
  {
    cache: build_storage(:cache),
    store: build_storage(:store)
  }
end

def build_storage(stage)
  case config.dig(stage, :provider)&.to_sym
  when :file_system then build_filesystem_storage(stage)
  when :s3 then build_s3_storage(stage)
  end
end

def build_filesystem_storage(stage)
  require 'shrine/storage/file_system'

  options = config.dig(stage, :options)
  Shrine::Storage::FileSystem.new(options[:directory], prefix: options[:prefix])
end

def build_s3_storage(stage)
  require 'shrine/storage/s3'

  options = config.dig(stage, :options)

  Shrine::Storage::S3.new(
    public: true,
    bucket: options.fetch(:bucket),
    region: options.fetch(:region),
    access_key_id: options.fetch(:access_key_id),
    secret_access_key: options.fetch(:secret_access_key),
    endpoint: options.fetch(:endpoint),
    prefix: options.fetch(:prefix)
  )
end

Shrine.storages = storages

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :derivatives, create_on_promote: true
Shrine.plugin :add_metadata
Shrine.plugin :determine_mime_type, analyzer: :marcel
Shrine.plugin :store_dimensions
Shrine.plugin :signature
Shrine.plugin :url_options,
              cache: config.dig(:cache, :url_options).symbolize_keys,
              store: config.dig(:store, :url_options).symbolize_keys
