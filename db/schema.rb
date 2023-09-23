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

ActiveRecord::Schema.define(version: 2023_09_22_181736) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "completions", force: :cascade do |t|
    t.datetime "completed_at", null: false
    t.bigint "nomination_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nomination_id"], name: "index_completions_on_nomination_id"
    t.index ["user_id"], name: "index_completions_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "title_usa"
    t.string "title_eu"
    t.string "title_jp"
    t.string "title_world"
    t.string "title_other"
    t.string "year"
    t.string "system"
    t.string "developer"
    t.string "genre"
    t.string "img_url"
    t.integer "time_to_beat"
    t.bigint "screenscraper_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "nominations", force: :cascade do |t|
    t.string "nomination_type", default: "gotm", null: false
    t.string "description"
    t.boolean "winner", default: false
    t.bigint "game_id"
    t.bigint "user_id"
    t.bigint "theme_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_nominations_on_game_id"
    t.index ["theme_id"], name: "index_nominations_on_theme_id"
    t.index ["user_id"], name: "index_nominations_on_user_id"
  end

  create_table "streaks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.date "last_incremented"
    t.integer "streak_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_streaks_on_user_id"
  end

  create_table "themes", force: :cascade do |t|
    t.date "creation_date", null: false
    t.string "title", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "nomination_type", default: "gotm"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "discord_id"
    t.string "old_discord_name"
    t.float "current_points", default: 0.0
    t.float "redeemed_points", default: 0.0
    t.float "earned_points", default: 0.0
    t.float "premium_points", default: 0.0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "premium_subscriber"
  end

  add_foreign_key "streaks", "users"
end
