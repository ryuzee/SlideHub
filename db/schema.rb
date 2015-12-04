# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151204125053) do

  create_table "categories", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",          limit: 4,                          null: false
    t.integer  "commentable_id",   limit: 4,                          null: false
    t.text     "comment",          limit: 65535,                      null: false
    t.datetime "created_at",                                          null: false
    t.datetime "modified_at"
    t.string   "commentable_type", limit: 255,   default: "Slide"
    t.string   "role",             limit: 255,   default: "comments"
  end

  add_index "comments", ["commentable_id"], name: "idx_comments_slide_id_key", using: :btree
  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "idx_comments_user_id_key", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "likes", force: :cascade do |t|
    t.string   "model",      limit: 50, null: false
    t.integer  "foreign_id", limit: 4,  null: false
    t.integer  "user_id",    limit: 4,  null: false
    t.datetime "created",               null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",        limit: 255,   null: false
    t.text     "value",      limit: 65535
    t.integer  "thing_id",   limit: 4
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "slides", force: :cascade do |t|
    t.integer  "user_id",        limit: 4,                     null: false
    t.string   "name",           limit: 255,                   null: false
    t.text     "description",    limit: 65535,                 null: false
    t.boolean  "downloadable",                 default: false, null: false
    t.integer  "category_id",    limit: 4,                     null: false
    t.datetime "created_at",                                   null: false
    t.datetime "modified_at"
    t.string   "key",            limit: 255,   default: ""
    t.string   "extension",      limit: 10,    default: "",    null: false
    t.integer  "convert_status", limit: 4,     default: 0
    t.integer  "total_view",     limit: 4,     default: 0,     null: false
    t.integer  "page_view",      limit: 4,     default: 0
    t.integer  "download_count", limit: 4,     default: 0,     null: false
    t.integer  "embedded_view",  limit: 4,     default: 0,     null: false
  end

  add_index "slides", ["category_id"], name: "idx_slides_category_id_key", using: :btree
  add_index "slides", ["key"], name: "index_slides_on_key", unique: true, using: :btree
  add_index "slides", ["page_view"], name: "idx_slides_page_view_key", using: :btree
  add_index "slides", ["user_id"], name: "idx_slides_user_id_key", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tags_old", force: :cascade do |t|
    t.string   "identifier", limit: 30
    t.string   "name",       limit: 30,             null: false
    t.string   "keyname",    limit: 30,             null: false
    t.datetime "created"
    t.datetime "modified"
    t.integer  "occurrence", limit: 4,  default: 0, null: false
  end

  add_index "tags_old", ["identifier", "keyname"], name: "UNIQUE_TAG", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 32,                    null: false
    t.string   "display_name",           limit: 128,                   null: false
    t.string   "password",               limit: 255,   default: "",    null: false
    t.boolean  "admin",                                default: false, null: false
    t.boolean  "disabled",                             default: false
    t.datetime "created_at",                                           null: false
    t.datetime "modified_at"
    t.text     "biography",              limit: 65535
    t.integer  "slides_count",           limit: 4,     default: 0
    t.string   "encrypted_password",     limit: 255,   default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
  end

  add_index "users", ["email"], name: "idx_username_ukey", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
