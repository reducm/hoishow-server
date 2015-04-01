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

ActiveRecord::Schema.define(version: 20150401092742) do

  create_table "api_auths", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.string   "user",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "areas", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "seats_count", limit: 4
    t.integer  "stadium_id",  limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "areas", ["stadium_id"], name: "index_areas_on_stadium_id", using: :btree

  create_table "cities", force: :cascade do |t|
    t.string   "pinyin",     limit: 255
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.boolean  "is_hot",     limit: 1
  end

  create_table "comments", force: :cascade do |t|
    t.string   "subject_type", limit: 255
    t.integer  "subject_id",   limit: 4
    t.text     "content",      limit: 65535
    t.integer  "user_id",      limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "concert_city_relations", force: :cascade do |t|
    t.integer  "concert_id", limit: 4
    t.integer  "city_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "concert_city_relations", ["city_id"], name: "index_concert_city_relations_on_city_id", using: :btree
  add_index "concert_city_relations", ["concert_id"], name: "index_concert_city_relations_on_concert_id", using: :btree

  create_table "concerts", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "poster",      limit: 255
    t.integer  "status",      limit: 4
  end

  create_table "districts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "city_id",    limit: 4
  end

  create_table "orders", force: :cascade do |t|
    t.decimal  "amount",                   precision: 10
    t.string   "concert_name", limit: 255
    t.string   "stadium_name", limit: 255
    t.string   "show_name",    limit: 255
    t.datetime "valid_time"
    t.string   "out_id",       limit: 255
    t.string   "city_name",    limit: 255
    t.string   "star_name",    limit: 255
    t.integer  "user_id",      limit: 4
    t.integer  "concert_id",   limit: 4
    t.integer  "city_id",      limit: 4
    t.integer  "stadium_id",   limit: 4
    t.integer  "star_id",      limit: 4
    t.integer  "show_id",      limit: 4
    t.integer  "status",       limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "seats_info",   limit: 255
  end

  add_index "orders", ["out_id"], name: "index_orders_on_out_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "purchase_id",   limit: 4
    t.string   "purchase_type", limit: 255
    t.string   "payment_type",  limit: 255
    t.integer  "status",        limit: 4
    t.string   "trade_id",      limit: 255
    t.datetime "pay_at"
    t.datetime "refund_at"
    t.decimal  "amount",                    precision: 10
    t.decimal  "refund_amount",             precision: 10
    t.string   "paid_origin",   limit: 255
    t.integer  "order_id",      limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "payments", ["order_id"], name: "index_payments_on_order_id", using: :btree

  create_table "show_area_relations", force: :cascade do |t|
    t.integer  "show_id",    limit: 4
    t.integer  "area_id",    limit: 4
    t.decimal  "price",                precision: 10
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "show_area_relations", ["area_id"], name: "index_show_area_relations_on_area_id", using: :btree
  add_index "show_area_relations", ["show_id"], name: "index_show_area_relations_on_show_id", using: :btree

  create_table "shows", force: :cascade do |t|
    t.decimal  "min_price",              precision: 10
    t.decimal  "max_price",              precision: 10
    t.string   "poster",     limit: 255
    t.string   "name",       limit: 255
    t.datetime "show_time"
    t.integer  "concert_id", limit: 4
    t.integer  "city_id",    limit: 4
    t.integer  "stadium_id", limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "shows", ["city_id"], name: "index_shows_on_city_id", using: :btree
  add_index "shows", ["concert_id"], name: "index_shows_on_concert_id", using: :btree
  add_index "shows", ["stadium_id"], name: "index_shows_on_stadium_id", using: :btree

  create_table "stadiums", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "address",     limit: 255
    t.decimal  "longitude",               precision: 10
    t.decimal  "latitude",                precision: 10
    t.integer  "city_id",     limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "district_id", limit: 4
  end

  add_index "stadiums", ["city_id"], name: "index_stadiums_on_city_id", using: :btree

  create_table "star_concert_relations", force: :cascade do |t|
    t.integer  "star_id",    limit: 4
    t.integer  "concert_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "star_concert_relations", ["concert_id"], name: "index_star_concert_relations_on_concert_id", using: :btree
  add_index "star_concert_relations", ["star_id"], name: "index_star_concert_relations_on_star_id", using: :btree

  create_table "stars", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "avatar",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "stars", ["name"], name: "index_stars_on_name", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "creator_type", limit: 255
    t.integer  "creator_id",   limit: 4
    t.string   "subject_type", limit: 255
    t.integer  "subject_id",   limit: 4
    t.text     "content",      limit: 65535
    t.boolean  "is_top",       limit: 1,     default: false
    t.integer  "city_id",      limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "user_follow_concerts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "concert_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_follow_concerts", ["concert_id"], name: "index_user_follow_concerts_on_concert_id", using: :btree
  add_index "user_follow_concerts", ["user_id"], name: "index_user_follow_concerts_on_user_id", using: :btree

  create_table "user_follow_stars", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "star_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_follow_stars", ["star_id"], name: "index_user_follow_stars_on_star_id", using: :btree
  add_index "user_follow_stars", ["user_id"], name: "index_user_follow_stars_on_user_id", using: :btree

  create_table "user_vote_concerts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "concert_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "city_id",    limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "mobile",             limit: 255
    t.string   "email",              limit: 255
    t.string   "encrypted_password", limit: 255
    t.datetime "last_sign_in_at"
    t.string   "avatar",             limit: 255
    t.string   "nickname",           limit: 255
    t.integer  "sex",                limit: 4
    t.datetime "birthday"
    t.string   "salt",               limit: 255
    t.boolean  "has_set_password",   limit: 1
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "api_token",          limit: 255
    t.integer  "api_expires_in",     limit: 4
  end

  create_table "videos", force: :cascade do |t|
    t.string   "url",        limit: 255
    t.integer  "star_id",    limit: 4
    t.integer  "concert_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "videos", ["concert_id"], name: "index_videos_on_concert_id", using: :btree
  add_index "videos", ["star_id"], name: "index_videos_on_star_id", using: :btree

end
