# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171222114708) do

  create_table "categories", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
  end

  create_table "comments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false
    t.integer "slide_id", null: false
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.datetime "modified_at"
    t.index ["slide_id"], name: "idx_comments_slide_id_key"
    t.index ["slide_id"], name: "index_comments_on_slide_id"
    t.index ["user_id"], name: "idx_comments_user_id_key"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "custom_files", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "path", null: false
    t.string "description"
    t.index ["path"], name: "idx_custom_files_ukey", unique: true
  end

  create_table "featured_slides", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "slide_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slide_id"], name: "idx_featured_slides_ukey", unique: true
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "var", null: false
    t.text "value", limit: 4294967295, collation: "utf8_bin"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "slides", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.boolean "downloadable", default: false, null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "modified_at"
    t.string "object_key", default: ""
    t.string "extension", limit: 10, default: "", null: false
    t.integer "convert_status", default: 0
    t.integer "total_view", default: 0, null: false
    t.integer "page_view", default: 0
    t.integer "download_count", default: 0, null: false
    t.integer "embedded_view", default: 0, null: false
    t.integer "num_of_pages", default: 0
    t.integer "comments_count", default: 0, null: false
    t.index ["category_id"], name: "idx_slides_category_id_key"
    t.index ["object_key"], name: "index_slides_on_object_key", unique: true
    t.index ["page_view"], name: "idx_slides_page_view_key"
    t.index ["user_id"], name: "idx_slides_user_id_key"
  end

  create_table "taggings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", collation: "utf8_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", limit: 32, null: false
    t.string "display_name", limit: 128, null: false
    t.string "password", default: "", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "disabled", default: false
    t.datetime "created_at", null: false
    t.datetime "modified_at"
    t.text "biography"
    t.integer "slides_count", default: 0
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string "username", null: false
    t.index ["email"], name: "idx_username_ukey", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
