# frozen_string_literal: true

require 'zip'

class Article
  class Import < ApplicationModel
    MANIFEST_FILE_NAME = 'manifest.toml'
    CONTENT_FILE_NAME = 'readme.md'

    attr_accessor :bundle,
                  :article,
                  :manifest

    validates :bundle,
              presence: true

    def save
      return false unless valid?

      ApplicationRecord.transaction do
        Zip::File.open(bundle) do |bundle|
          load_manifest!(bundle)
          self.article ||= Article.find_by(id: manifest[:id]) || Article.new
          apply_manifest!
          load_article_content!(bundle)
          attach_files!(bundle)
          create_primary_image!(bundle)
        end

        article.save
      end
    end

    private

    def parse_bundle!
      Zip::File.open(bundle) do |bundle|
      end
    end

    def load_manifest!(bundle)
      entry = bundle.entries.find { |e| e.name.downcase == MANIFEST_FILE_NAME }

      self.manifest = TOML.load(entry.get_input_stream.read)
                          .with_indifferent_access
    end

    def load_article_content!(bundle)
      entry = bundle.entries.find { |e| e.name.downcase == CONTENT_FILE_NAME }
      article.content = entry.get_input_stream.read
    end

    def attach_files!(bundle)
      article.content.attachment_urls.each do |attachemnt_url|
        path = attachemnt_url.gsub(%r{^\./}, '')
        entry = bundle.entries.find { |e| e.name == path && e.file? }
        next unless entry

        image_io = entry.get_input_stream
        # Required by underlying image processing library
        image_io.define_singleton_method(:path) { attachemnt_url }

        article.images.build(image: image_io, original_path: attachemnt_url)
      end
    end

    def create_primary_image!(bundle)
      primary_image = find_primary_image ||
                      upload_primary_image!(bundle) ||
                      article.images.first

      return unless primary_image

      article.images.each { |i| i.primary = false }
      primary_image.primary = true
    end

    def find_primary_image
      article
        .images
        .find { |image| image.original_path == manifest[:primary_image] }
    end

    def upload_primary_image!(bundle)
      return if manifest[:primary_image].blank?

      entry = bundle
              .entries
              .find do |e|
                e.file? &&
                  e.name == manifest[:primary_image].gsub(%r{^\./}, '')
              end

      return unless entry

      article.images.build(image: entry.get_input_stream,
                           original_path: manifest[:primary_image])
    end

    def apply_manifest!
      article.attributes = manifest.slice(:id, :title, :slug, :published,
                                          :publish_at)
    end
  end
end
