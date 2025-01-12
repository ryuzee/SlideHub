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

ActiveRecord::Schema[7.2].define(version: 2025_01_12_083417) do
  create_table "active_storage_attachments", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "name_en", default: "", null: false
    t.string "name_ja", default: "", null: false
  end

  create_table "comments", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "slide_id", null: false
    t.text "comment", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil
    t.index ["slide_id"], name: "idx_comments_slide_id_key"
    t.index ["slide_id"], name: "index_comments_on_slide_id"
    t.index ["user_id"], name: "idx_comments_user_id_key"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "custom_files", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "path", null: false
    t.string "description"
    t.index ["path"], name: "idx_custom_files_ukey", unique: true
  end

  create_table "featured_slides", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "slide_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["slide_id"], name: "idx_featured_slides_ukey", unique: true
  end

  create_table "pages", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "path", limit: 30, null: false
    t.string "title", null: false
    t.text "content", size: :long
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["path"], name: "idx_pages_ukey", unique: true
  end

  create_table "sessions", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "var", null: false
    t.text "value", size: :long, collation: "utf8_bin"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["var"], name: "idx_settings_key"
  end

  create_table "slides", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.boolean "downloadable", default: false, null: false
    t.integer "category_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil
    t.string "object_key", default: ""
    t.string "extension", limit: 10, default: "", null: false
    t.integer "convert_status", default: 0
    t.integer "total_view", default: 0, null: false
    t.integer "page_view", default: 0
    t.integer "download_count", default: 0, null: false
    t.integer "embedded_view", default: 0, null: false
    t.integer "num_of_pages", default: 0
    t.integer "comments_count", default: 0, null: false
    t.boolean "private", default: false, null: false
    t.index ["category_id"], name: "idx_slides_category_id_key"
    t.index ["object_key"], name: "index_slides_on_object_key", unique: true
    t.index ["page_view"], name: "idx_slides_page_view_key"
    t.index ["user_id"], name: "idx_slides_user_id_key"
  end

  create_table "taggings", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tenants", charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "email", limit: 32, null: false
    t.string "display_name", limit: 128, null: false
    t.string "password", default: "", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "disabled", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil
    t.text "biography"
    t.integer "slides_count", default: 0
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.binary "avatar"
    t.string "username", null: false
    t.string "provider"
    t.string "uid"
    t.string "token"
    t.string "twitter_account", limit: 15
    t.index ["email"], name: "idx_username_ukey", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
