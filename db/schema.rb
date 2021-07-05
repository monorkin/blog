# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_04_144106) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "article_images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "image_data"
    t.string "article_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "primary", default: false, null: false
    t.text "original_path"
    t.index ["article_id", "primary"], name: "index_article_images_on_article_id_and_primary", unique: true, where: "(\"primary\" = true)"
    t.index ["article_id"], name: "index_article_images_on_article_id"
    t.index ["primary"], name: "index_article_images_on_primary"
  end

  create_table "article_statistics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "article_id"
    t.bigint "view_count", default: 0, null: false
    t.jsonb "referrer_visit_counts", default: {}, null: false
    t.jsonb "visit_counts_per_month", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["article_id"], name: "index_article_statistics_on_article_id"
  end

  create_table "article_taggings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "article_id", null: false
    t.uuid "tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["article_id", "tag_id"], name: "index_article_taggings_on_article_id_and_tag_id", unique: true
    t.index ["article_id"], name: "index_article_taggings_on_article_id"
    t.index ["tag_id"], name: "index_article_taggings_on_tag_id"
  end

  create_table "articles", id: :string, force: :cascade do |t|
    t.text "title", default: "", null: false
    t.text "content", default: "", null: false
    t.text "slug", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "publish_at"
    t.boolean "published", default: false, null: false
    t.datetime "published_at", precision: 6, default: -> { "COALESCE(publish_at, created_at)" }
    t.string "thread"
    t.tsvector "searchable", default: -> { "(setweight(to_tsvector('english'::regconfig, title), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, content), 'B'::\"char\"))" }
    t.index ["published_at"], name: "index_articles_on_published_at"
    t.index ["searchable"], name: "index_articles_on_searchable", using: :gin
    t.index ["thread"], name: "index_articles_on_thread"
  end

  create_table "tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.citext "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "username"
    t.text "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "unconfirmed_otp_secret"
    t.text "otp_secret"
    t.datetime "last_otp_used_at"
    t.datetime "last_login_at"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "article_images", "articles"
  add_foreign_key "article_taggings", "articles"
  add_foreign_key "article_taggings", "tags"
end
