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

ActiveRecord::Schema[8.0].define(version: 2025_07_21_014202) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "board_shared_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "board_id", null: false
    t.bigint "user_id"
    t.string "token", null: false
    t.integer "permission", default: 0, null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_board_shared_links_on_board_id"
    t.index ["token"], name: "index_board_shared_links_on_token", unique: true
    t.index ["user_id"], name: "index_board_shared_links_on_user_id"
  end

  create_table "boards", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_boards_on_user_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.bigint "board_id", null: false
    t.index ["board_id"], name: "index_lists_on_board_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "priority"
    t.datetime "completed_at"
    t.date "due_date"
    t.time "due_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "list_id", null: false
    t.index ["list_id"], name: "index_tasks_on_list_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "profile_picture_url"
    t.string "photo_url"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "board_shared_links", "boards"
  add_foreign_key "board_shared_links", "users"
  add_foreign_key "boards", "users"
  add_foreign_key "lists", "boards"
  add_foreign_key "tasks", "lists"
end
