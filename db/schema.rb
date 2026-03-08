# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.2].define(version: 2026_03_08_100000) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "article_link_previews", force: :cascade do |t|
    t.integer "article_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.text "title"
    t.datetime "updated_at", null: false
    t.text "url", null: false
    t.index ["article_id", "url"], name: "index_article_link_previews_on_article_id_and_url", unique: true
    t.index ["article_id"], name: "index_article_link_previews_on_article_id"
  end

  create_table "articles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "thread"
    t.text "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["thread"], name: "index_articles_on_thread"
  end

  create_table "entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "entryable_id", null: false
    t.string "entryable_type", null: false
    t.datetime "publish_at"
    t.boolean "published", default: false, null: false
    t.datetime "published_at"
    t.text "slug", default: "", null: false
    t.string "slug_id", null: false
    t.datetime "updated_at", null: false
    t.index ["entryable_type", "entryable_id"], name: "index_entries_on_entryable"
    t.index ["published"], name: "index_entries_on_published"
    t.index ["published_at"], name: "index_entries_on_published_at"
    t.index ["slug_id"], name: "index_entries_on_slug_id", unique: true
  end

  create_table "snaps", force: :cascade do |t|
    t.text "caption"
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tag_taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.bigint "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_tag_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id", "tag_id"], name: "index_tag_taggings_on_taggable_type_and_taggable_id_and_tag_id", unique: true
    t.index ["taggable_type", "taggable_id"], name: "index_tag_taggings_on_taggable"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "talks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "event", null: false
    t.text "event_url"
    t.datetime "held_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.text "video_mirror_url"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "login_attempt_count", default: 0, null: false
    t.datetime "login_attempted_at", null: false
    t.text "password_digest"
    t.datetime "updated_at", null: false
    t.text "username"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "article_link_previews", "articles"
  add_foreign_key "tag_taggings", "tags"
end
