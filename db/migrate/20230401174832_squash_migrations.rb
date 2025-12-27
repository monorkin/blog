# frozen_string_literal: true

class SquashMigrations < ActiveRecord::Migration[7.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension 'citext'
    enable_extension 'pgcrypto'
    enable_extension 'plpgsql'

    create_table 'action_text_rich_texts', force: :cascade do |t|
      t.string 'name', null: false
      t.text 'body'
      t.string 'record_type', null: false
      t.bigint 'record_id', null: false
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.index %w[record_type record_id name], name: 'index_action_text_rich_texts_uniqueness', unique: true
    end

    create_table 'active_storage_attachments', force: :cascade do |t|
      t.string 'name', null: false
      t.string 'record_type', null: false
      t.bigint 'record_id', null: false
      t.bigint 'blob_id', null: false
      t.datetime 'created_at', null: false
      t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
      t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness',
                                                      unique: true
    end

    create_table 'active_storage_blobs', force: :cascade do |t|
      t.string 'key', null: false
      t.string 'filename', null: false
      t.string 'content_type'
      t.text 'metadata'
      t.string 'service_name', null: false
      t.bigint 'byte_size', null: false
      t.string 'checksum'
      t.datetime 'created_at', null: false
      t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
    end

    create_table 'active_storage_variant_records', force: :cascade do |t|
      t.bigint 'blob_id', null: false
      t.string 'variation_digest', null: false
      t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
    end

    create_table 'article_attachments', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
      t.jsonb 'attachment_data'
      t.string 'article_id', null: false
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.boolean 'primary', default: false, null: false
      t.text 'original_path'
      t.index %w[article_id primary], name: 'index_article_attachments_on_article_id_and_primary', unique: true,
                                      where: '("primary" = true)'
      t.index ['article_id'], name: 'index_article_attachments_on_article_id'
      t.index ['primary'], name: 'index_article_attachments_on_primary'
    end

    create_table 'articles', force: :cascade do |t|
      t.string 'slug_id', null: false
      t.text 'title', default: '', null: false
      t.text 'old_content', default: '', null: false
      t.text 'slug', default: '', null: false
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.datetime 'publish_at', precision: nil
      t.boolean 'published', default: false, null: false
      t.virtual 'published_at', type: :datetime, as: 'COALESCE(publish_at, created_at)', stored: true
      t.string 'thread'
      t.index ['published_at'], name: 'index_articles_on_published_at'
      t.index ['thread'], name: 'index_articles_on_thread'
    end

    create_table 'users', force: :cascade do |t|
      t.text 'username'
      t.text 'password_digest'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.datetime 'login_attempted_at', null: false
      t.integer 'login_attempt_count', default: 0, null: false
      t.index ['username'], name: 'index_users_on_username', unique: true
    end

    add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
    add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
  end
end
