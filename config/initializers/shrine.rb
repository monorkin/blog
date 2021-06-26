# frozen_string_literal: true

require 'shrine'
require 'shrine/storage/file_system'
require 'shrine/storage/s3'

def storages
  {
    cache: build_storage(:cache),
    store: build_storage(:store)
  }
end

def build_storage(stage)
  case Rails.application.credentials.dig(:file_storage, :provider, stage)&.to_sym
  when :file_system then build_filesystem_storage(stage)
  when :s3 then build_s3_storage(stage)
  end
end

def build_filesystem_storage(stage)
  options = Rails.application.credentials.dig(:file_storage,
                                              :file_system_provider_options,
                                              stage)

  Shrine::Storage::FileSystem.new(options[:directory], prefix: options[:prefix])
end

def build_s3_storage(stage)
  options = Rails.application.credentials.dig(:file_storage,
                                              :s3_provider_options, stage)

  Shrine::Storage::S3.new(
    bucket: options[:bucker],
    region: options[:region],
    access_key_id: options[:access_key_id],
    secret_access_key: options[:secret_access_key]
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
