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

ActiveRecord::Schema.define(version: 20150714071930) do

  create_table "admins", force: :cascade do |t|
    t.string   "email",              limit: 255
    t.string   "name",               limit: 255
    t.string   "encrypted_password", limit: 255
    t.string   "salt",               limit: 255
    t.datetime "last_sign_in_at"
    t.integer  "admin_type",         limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "is_block",           limit: 1,   default: false
    t.string   "api_token",          limit: 255
  end

  create_table "api_auths", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.string   "user",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "secretcode", limit: 255
  end

  create_table "areas", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "seats_count", limit: 4
    t.integer  "stadium_id",  limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "sort_by",     limit: 255
  end

  add_index "areas", ["stadium_id"], name: "index_areas_on_stadium_id", using: :btree

  create_table "banners", force: :cascade do |t|
    t.integer  "admin_id",     limit: 4
    t.string   "poster",       limit: 255
    t.string   "subject_type", limit: 255
    t.integer  "subject_id",   limit: 4
    t.text     "description",  limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "position",     limit: 4
  end

  add_index "banners", ["admin_id"], name: "index_banners_on_admin_id", using: :btree

  create_table "cities", force: :cascade do |t|
    t.string   "pinyin",     limit: 255
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.boolean  "is_hot",     limit: 1
  end

  create_table "comments", force: :cascade do |t|
    t.text     "content",      limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "parent_id",    limit: 4
    t.integer  "topic_id",     limit: 4
    t.integer  "creator_id",   limit: 4
    t.string   "creator_type", limit: 255
  end

  create_table "concert_city_relations", force: :cascade do |t|
    t.integer  "concert_id",  limit: 4
    t.integer  "city_id",     limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "base_number", limit: 4, default: 0
  end

  add_index "concert_city_relations", ["city_id"], name: "index_concert_city_relations_on_city_id", using: :btree
  add_index "concert_city_relations", ["concert_id"], name: "index_concert_city_relations_on_concert_id", using: :btree

  create_table "concerts", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "description",      limit: 65535
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "poster",           limit: 255
    t.integer  "status",           limit: 4
    t.integer  "is_show",          limit: 4,     default: 0
    t.boolean  "is_top",           limit: 1,     default: false
    t.string   "description_time", limit: 255
  end

  create_table "districts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "city_id",    limit: 4
  end

  create_table "expresses", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.string   "user_name",    limit: 255
    t.string   "user_address", limit: 255
    t.string   "user_mobile",  limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "province",     limit: 255
    t.string   "city",         limit: 255
    t.string   "district",     limit: 255
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "send_type",         limit: 4
    t.string   "title",             limit: 255
    t.text     "content",           limit: 65535
    t.string   "subject_type",      limit: 255
    t.integer  "subject_id",        limit: 4
    t.string   "creator_type",      limit: 255
    t.integer  "creator_id",        limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "notification_text", limit: 255
    t.string   "link_url",          limit: 255
    t.string   "task_id",           limit: 255
  end

  create_table "orders", force: :cascade do |t|
    t.decimal  "amount",                           precision: 10, scale: 2
    t.string   "concert_name",       limit: 255
    t.string   "stadium_name",       limit: 255
    t.string   "show_name",          limit: 255
    t.datetime "valid_time"
    t.string   "out_id",             limit: 255
    t.string   "city_name",          limit: 255
    t.integer  "user_id",            limit: 4
    t.integer  "concert_id",         limit: 4
    t.integer  "city_id",            limit: 4
    t.integer  "stadium_id",         limit: 4
    t.integer  "show_id",            limit: 4
    t.integer  "status",             limit: 4
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "express_id",         limit: 255
    t.string   "user_address",       limit: 255
    t.string   "user_name",          limit: 255
    t.string   "user_mobile",        limit: 255
    t.text     "remark",             limit: 65535
    t.string   "out_trade_no",       limit: 255
    t.string   "buy_origin",         limit: 255
    t.integer  "channel",            limit: 4
    t.string   "open_trade_no",      limit: 255
    t.datetime "generate_ticket_at"
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
    t.decimal  "amount",                    precision: 10, scale: 2
    t.decimal  "refund_amount",             precision: 10, scale: 2
    t.string   "paid_origin",   limit: 255
    t.integer  "order_id",      limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "payments", ["order_id"], name: "index_payments_on_order_id", using: :btree

  create_table "seats", force: :cascade do |t|
    t.integer  "show_id",    limit: 4
    t.integer  "area_id",    limit: 4
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.text     "seats_info", limit: 65535
    t.integer  "row",        limit: 4
    t.integer  "column",     limit: 4
    t.integer  "status",     limit: 4
    t.string   "name",       limit: 255
    t.decimal  "price",                    precision: 10, scale: 2
    t.integer  "order_id",   limit: 4
    t.string   "channels",   limit: 255
  end

  add_index "seats", ["show_id", "area_id"], name: "index_seats_on_show_id_and_area_id", using: :btree

  create_table "show_area_relations", force: :cascade do |t|
    t.integer  "show_id",     limit: 4
    t.integer  "area_id",     limit: 4
    t.decimal  "price",                   precision: 6, scale: 2
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.boolean  "is_sold_out", limit: 1,                           default: false
    t.integer  "seats_count", limit: 4
    t.string   "channels",    limit: 255
  end

  add_index "show_area_relations", ["area_id"], name: "index_show_area_relations_on_area_id", using: :btree
  add_index "show_area_relations", ["show_id"], name: "index_show_area_relations_on_show_id", using: :btree

  create_table "shows", force: :cascade do |t|
    t.decimal  "min_price",                      precision: 10, scale: 2
    t.decimal  "max_price",                      precision: 10, scale: 2
    t.string   "poster",           limit: 255
    t.string   "name",             limit: 255
    t.datetime "show_time"
    t.integer  "concert_id",       limit: 4
    t.integer  "city_id",          limit: 4
    t.integer  "stadium_id",       limit: 4
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.text     "description",      limit: 65535
    t.integer  "status",           limit: 4
    t.boolean  "is_display",       limit: 1,                              default: false
    t.integer  "ticket_type",      limit: 4
    t.boolean  "is_top",           limit: 1,                              default: false
    t.string   "stadium_map",      limit: 255
    t.integer  "seat_type",        limit: 4
    t.integer  "mode",             limit: 4
    t.string   "ticket_pic",       limit: 255
    t.string   "description_time", limit: 255
  end

  add_index "shows", ["city_id"], name: "index_shows_on_city_id", using: :btree
  add_index "shows", ["concert_id"], name: "index_shows_on_concert_id", using: :btree
  add_index "shows", ["stadium_id"], name: "index_shows_on_stadium_id", using: :btree

  create_table "simditor_images", force: :cascade do |t|
    t.string   "image",      limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "stadiums", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "address",     limit: 255
    t.decimal  "longitude",               precision: 10, scale: 6
    t.decimal  "latitude",                precision: 10, scale: 6
    t.integer  "city_id",     limit: 4
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "district_id", limit: 4
    t.string   "pic",         limit: 255
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
    t.string   "name",        limit: 255
    t.string   "avatar",      limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "position",    limit: 4
    t.string   "video",       limit: 255
    t.boolean  "is_display",  limit: 1,     default: false
    t.string   "poster",      limit: 255
    t.text     "description", limit: 65535
  end

  add_index "stars", ["name"], name: "index_stars_on_name", using: :btree

  create_table "startups", force: :cascade do |t|
    t.string   "pic",        limit: 255
    t.datetime "valid_time"
    t.boolean  "is_display", limit: 1,   default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "area_id",         limit: 4
    t.integer  "show_id",         limit: 4
    t.decimal  "price",                       precision: 10, scale: 2
    t.integer  "order_id",        limit: 4
    t.string   "code",            limit: 255
    t.datetime "code_valid_time"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "status",          limit: 4
    t.integer  "admin_id",        limit: 4
    t.datetime "checked_at"
    t.string   "seat_name",       limit: 255
  end

  add_index "tickets", ["area_id"], name: "index_tickets_on_area_id", using: :btree
  add_index "tickets", ["order_id"], name: "index_tickets_on_order_id", using: :btree
  add_index "tickets", ["show_id"], name: "index_tickets_on_show_id", using: :btree

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

  create_table "user_follow_shows", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "show_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_follow_shows", ["show_id"], name: "index_user_follow_shows_on_show_id", using: :btree
  add_index "user_follow_shows", ["user_id"], name: "index_user_follow_shows_on_user_id", using: :btree

  create_table "user_follow_stars", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "star_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_follow_stars", ["star_id"], name: "index_user_follow_stars_on_star_id", using: :btree
  add_index "user_follow_stars", ["user_id"], name: "index_user_follow_stars_on_user_id", using: :btree

  create_table "user_like_topics", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "topic_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "user_message_relations", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "message_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "is_new",     limit: 1, default: true
  end

  add_index "user_message_relations", ["message_id"], name: "index_user_message_relations_on_message_id", using: :btree
  add_index "user_message_relations", ["user_id"], name: "index_user_message_relations_on_user_id", using: :btree

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
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "api_token",          limit: 255
    t.integer  "api_expires_in",     limit: 4
    t.boolean  "is_block",           limit: 1,   default: false
    t.integer  "bike_user_id",       limit: 4
    t.integer  "channel",            limit: 4
  end

  add_index "users", ["bike_user_id"], name: "index_users_on_bike_user_id", using: :btree
  add_index "users", ["mobile"], name: "index_users_on_mobile", using: :btree

  create_table "videos", force: :cascade do |t|
    t.string   "url",        limit: 255
    t.integer  "star_id",    limit: 4
    t.integer  "concert_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.boolean  "is_main",    limit: 1
    t.string   "source",     limit: 255
    t.string   "snapshot",   limit: 255
  end

  add_index "videos", ["concert_id"], name: "index_videos_on_concert_id", using: :btree
  add_index "videos", ["star_id"], name: "index_videos_on_star_id", using: :btree

end
