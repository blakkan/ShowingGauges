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

ActiveRecord::Schema.define(version: 20171030092610) do

  create_table "bins", force: :cascade do |t|
    t.integer "qty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
    t.integer "sku_id"
    t.index ["location_id"], name: "index_bins_on_location_id"
    t.index ["sku_id"], name: "index_bins_on_sku_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "comment"
    t.boolean "is_retired", default: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "skus", force: :cascade do |t|
    t.string "name"
    t.string "comment"
    t.integer "minimum_stocking_level", default: 0
    t.boolean "is_retired", default: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bu"
    t.string "description"
    t.string "category"
    t.decimal "cost", precision: 10, scale: 2
    t.index ["user_id"], name: "index_skus_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "qty"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "from_id"
    t.integer "to_id"
    t.integer "sku_id"
    t.integer "user_id"
    t.index ["from_id"], name: "index_transactions_on_from_id"
    t.index ["sku_id"], name: "index_transactions_on_sku_id"
    t.index ["to_id"], name: "index_transactions_on_to_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "comment"
    t.string "encrypted_password"
    t.boolean "is_retired", default: false
    t.string "capabilities"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_users_on_user_id"
  end

end
