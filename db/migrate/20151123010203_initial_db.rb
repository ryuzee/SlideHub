class InitialDb < ActiveRecord::Migration
  def self.up
    #drop_table "schema_migrations"

    create_table "cake_sessions" do |t|
      t.text    "data",    limit: 65535, null: false
      t.integer "expires", limit: 4,     null: false
    end unless ActiveRecord::Base.connection.table_exists?('cake_sessions')

    create_table "categories" do |t|
      t.string "name", limit: 255, null: false
    end unless ActiveRecord::Base.connection.table_exists?('categories')

    create_table "comments" do |t|
      t.integer  "user_id",  limit: 4,     null: false
      t.integer  "slide_id", limit: 4,     null: false
      t.text     "content",  limit: 65535, null: false
      t.datetime "created",                null: false
      t.datetime "modified"
    end unless ActiveRecord::Base.connection.table_exists?('comments')

    add_index "comments", ["slide_id"], name: "idx_comments_slide_id_key", using: :btree unless ActiveRecord::Base.connection.index_exists?('comments', ["slide_id"], :name => 'idx_comments_slide_id_key')
    add_index "comments", ["user_id"], name: "idx_comments_user_id_key", using: :btree unless ActiveRecord::Base.connection.index_exists?('comments', ["user_id"], :name => 'idx_comments_user_id_key')

    create_table "configs", primary_key: "name" do |t|
      t.string   "value",    limit: 255, default: "", null: false
      t.datetime "created",                           null: false
      t.datetime "modified"
    end unless ActiveRecord::Base.connection.table_exists?('configs')

    create_table "custom_contents", primary_key: "name" do |t|
      t.text     "value",    limit: 65535, null: false
      t.datetime "created",                null: false
      t.datetime "modified"
    end unless ActiveRecord::Base.connection.table_exists?('custom_contents')

    create_table "slides" do |t|
      t.integer  "user_id",        limit: 4,                     null: false
      t.string   "name",           limit: 255,                   null: false
      t.text     "description",    limit: 65535,                 null: false
      t.boolean  "downloadable",                 default: false, null: false
      t.integer  "category_id",    limit: 4,                     null: false
      t.datetime "created",                                      null: false
      t.datetime "modified"
      t.string   "key",            limit: 255,   default: ""
      t.string   "extension",      limit: 10,    default: "",    null: false
      t.integer  "convert_status", limit: 4,     default: 0
      t.integer  "total_view",     limit: 4,     default: 0,     null: false
      t.integer  "page_view",      limit: 4,     default: 0
      t.integer  "download_count", limit: 4,     default: 0,     null: false
      t.integer  "embedded_view",  limit: 4,     default: 0,     null: false
    end unless ActiveRecord::Base.connection.table_exists?('slides')

    add_index "slides", ["category_id"], name: "idx_slides_category_id_key", using: :btree unless ActiveRecord::Base.connection.index_exists?('slides', ["category_id"], :name => 'idx_slides_category_id_key')
    add_index "slides", ["page_view"], name: "idx_slides_page_view_key", using: :btree unless ActiveRecord::Base.connection.index_exists?('slides', ["page_view"], :name => 'idx_slides_page_view_key')
    add_index "slides", ["user_id"], name: "idx_slides_user_id_key", using: :btree unless ActiveRecord::Base.connection.index_exists?('slides', ["user_id"], :name => 'idx_slides_user_id_key')

    create_table "tagged" do |t|
      t.string   "foreign_key",  limit: 36,              null: false
      t.string   "tag_id",       limit: 36,              null: false
      t.string   "model",        limit: 255,             null: false
      t.string   "language",     limit: 6
      t.datetime "created"
      t.datetime "modified"
      t.integer  "times_tagged", limit: 4,   default: 1, null: false
    end unless ActiveRecord::Base.connection.table_exists?('tagged')

    add_index "tagged", ["language"], name: "INDEX_LANGUAGE", using: :btree unless ActiveRecord::Base.connection.index_exists?('tagged', ["language"], :name => 'INDEX_LANGUAGE')
    add_index "tagged", ["model", "foreign_key", "tag_id", "language"], name: "UNIQUE_TAGGING", unique: true, using: :btree unless ActiveRecord::Base.connection.index_exists?('tagged', ["model", "foreign_key", "tag_id", "language"], :name => 'UNIQUE_TAGGING')
    add_index "tagged", ["model"], name: "INDEX_TAGGED", using: :btree unless ActiveRecord::Base.connection.index_exists?('tagged', ["model"], :name => 'INDEX_TAGGED')

    create_table "tags" do |t|
      t.string   "identifier", limit: 30
      t.string   "name",       limit: 30,             null: false
      t.string   "keyname",    limit: 30,             null: false
      t.datetime "created"
      t.datetime "modified"
      t.integer  "occurrence", limit: 4,  default: 0, null: false
    end unless ActiveRecord::Base.connection.table_exists?('tags')

    add_index "tags", ["identifier", "keyname"], name: "UNIQUE_TAG", unique: true, using: :btree unless ActiveRecord::Base.connection.index_exists?('tags', ["identifier", "keyname"], :name => 'UNIQUE_TAG')

    create_table "users" do |t|
      t.string   "username",     limit: 32,                    null: false
      t.string   "display_name", limit: 128,                   null: false
      t.string   "password",     limit: 255,                   null: false
      t.boolean  "admin",                      default: false, null: false
      t.boolean  "disabled",                   default: false
      t.datetime "created",                                    null: false
      t.datetime "modified"
      t.text     "biography",    limit: 65535
      t.integer  "slides_count", limit: 4,     default: 0
    end unless ActiveRecord::Base.connection.table_exists?('users')

    add_index "users", ["username"], name: "idx_username_ukey", unique: true, using: :btree unless ActiveRecord::Base.connection.index_exists?('users', ["username"], :name => 'idx_username_ukey')

  end
end
