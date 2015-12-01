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

ActiveRecord::Schema.define(version: 20151127072438) do

  create_table "activity_statuses", force: :cascade do |t|
    t.string   "boom_id",    limit: 255
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.integer  "value",      limit: 4
    t.boolean  "removed",    limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "activity_statuses", ["boom_id"], name: "index_activity_statuses_on_boom_id", using: :btree

  create_table "activity_track_relations", force: :cascade do |t|
    t.integer  "boom_activity_id", limit: 4
    t.integer  "boom_track_id",    limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "activity_verifieds", force: :cascade do |t|
    t.string   "boom_id",            limit: 255
    t.string   "url",                limit: 255
    t.string   "cover",              limit: 255
    t.string   "name",               limit: 255
    t.string   "publisher",          limit: 255
    t.string   "file",               limit: 255
    t.integer  "tag_visible_number", limit: 4
    t.text     "description",        limit: 65535
    t.boolean  "verified",           limit: 1
    t.boolean  "removed",            limit: 1
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "activity_verifieds", ["boom_id"], name: "index_activity_verifieds_on_boom_id", using: :btree
  add_index "activity_verifieds", ["name"], name: "index_activity_verifieds_on_name", using: :btree

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
    t.string   "boom_id",    limit: 255
    t.boolean  "verified",   limit: 1
  end

  create_table "areas", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "seats_count", limit: 4
    t.integer  "stadium_id",  limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "sort_by",     limit: 255
    t.text     "seats_info",  limit: 16777215
    t.text     "coordinates", limit: 65535
    t.string   "color",       limit: 255
    t.integer  "event_id",    limit: 4
    t.integer  "left_seats",  limit: 4
  end

  add_index "areas", ["event_id"], name: "index_areas_on_event_id", using: :btree
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

  create_table "boom_activities", force: :cascade do |t|
    t.string   "boom_id",            limit: 255
    t.string   "boom_recommend_id",  limit: 255
    t.string   "boom_page_id",       limit: 255
    t.string   "boom_status_id",     limit: 255
    t.string   "url_share",          limit: 255
    t.string   "url",                limit: 255
    t.string   "cover",              limit: 255
    t.string   "owner",              limit: 255
    t.string   "name",               limit: 255
    t.string   "publisher",          limit: 255
    t.string   "file",               limit: 255
    t.integer  "tag_visible_number", limit: 4
    t.text     "description",        limit: 65535
    t.boolean  "removed",            limit: 1
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "showtime",           limit: 255
    t.integer  "boom_location_id",   limit: 4
    t.integer  "mode",               limit: 4
    t.integer  "boom_admin_id",      limit: 4
    t.integer  "status",             limit: 4
    t.boolean  "is_display",         limit: 1
    t.boolean  "is_top",             limit: 1
    t.boolean  "is_hot",             limit: 1
  end

  add_index "boom_activities", ["boom_id"], name: "index_boom_activities_on_boom_id", using: :btree
  add_index "boom_activities", ["name"], name: "index_boom_activities_on_name", using: :btree

  create_table "boom_admins", force: :cascade do |t|
    t.string   "email",              limit: 255
    t.string   "name",               limit: 255
    t.string   "encrypted_password", limit: 255
    t.string   "salt",               limit: 255
    t.datetime "last_sign_in_at"
    t.integer  "admin_type",         limit: 4
    t.boolean  "is_block",           limit: 1,   default: false
    t.string   "api_token",          limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "email_confirmed",    limit: 1,   default: false
    t.string   "confirm_token",      limit: 255
  end

  create_table "boom_albums", force: :cascade do |t|
    t.integer  "collaborator_id", limit: 4
    t.string   "image",           limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "is_cover",        limit: 1,   default: false
  end

  add_index "boom_albums", ["collaborator_id"], name: "index_boom_albums_on_collaborator_id", using: :btree

  create_table "boom_articles", force: :cascade do |t|
    t.string   "boom_id",          limit: 255
    t.string   "boom_location_id", limit: 255
    t.string   "title",            limit: 255
    t.string   "subtitle",         limit: 255
    t.string   "url_alias",        limit: 255
    t.string   "url_short",        limit: 255
    t.string   "url_origin",       limit: 255
    t.string   "cover",            limit: 255
    t.string   "summary",          limit: 255
    t.text     "content_html",     limit: 65535
    t.text     "content_json",     limit: 65535
    t.boolean  "verified",         limit: 1
    t.boolean  "removed",          limit: 1
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "boom_articles", ["boom_id"], name: "index_boom_articles_on_boom_id", using: :btree

  create_table "boom_banners", force: :cascade do |t|
    t.string   "poster",       limit: 255
    t.string   "subject_type", limit: 255
    t.integer  "subject_id",   limit: 4
    t.integer  "position",     limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "boom_cities", force: :cascade do |t|
    t.string   "boom_id",      limit: 255
    t.string   "boom_page_id", limit: 255
    t.string   "name",         limit: 255
    t.string   "name_english", limit: 255
    t.string   "name_chinese", limit: 255
    t.string   "cover",        limit: 255
    t.boolean  "removed",      limit: 1
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "boom_cities", ["boom_id"], name: "index_boom_cities_on_boom_id", using: :btree

  create_table "boom_comments", force: :cascade do |t|
    t.integer  "boom_topic_id", limit: 4
    t.integer  "parent_id",     limit: 4
    t.integer  "creator_id",    limit: 4
    t.string   "creator_type",  limit: 255
    t.string   "avatar",        limit: 255
    t.text     "content",       limit: 65535
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "is_hidden",     limit: 1,     default: false
  end

  create_table "boom_feedbacks", force: :cascade do |t|
    t.string   "content",    limit: 255
    t.string   "contact",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id",    limit: 4
    t.boolean  "status",     limit: 1
  end

  create_table "boom_locations", force: :cascade do |t|
    t.string   "boom_id",                    limit: 255
    t.string   "boom_city_id",               limit: 255
    t.string   "boom_activity_id",           limit: 255
    t.string   "boom_city_activity_page_id", limit: 255
    t.string   "boom_city_page_id",          limit: 255
    t.string   "name",                       limit: 255
    t.string   "name_english",               limit: 255
    t.string   "name_chinese",               limit: 255
    t.string   "phone",                      limit: 255
    t.string   "weibo",                      limit: 255
    t.string   "wechat",                     limit: 255
    t.decimal  "longitude",                              precision: 10, scale: 6
    t.decimal  "latitude",                               precision: 10, scale: 6
    t.string   "address",                    limit: 255
    t.string   "image",                      limit: 255
    t.boolean  "removed",                    limit: 1
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
  end

  add_index "boom_locations", ["boom_id"], name: "index_boom_locations_on_boom_id", using: :btree

  create_table "boom_messages", force: :cascade do |t|
    t.integer  "boom_admin_id", limit: 4
    t.integer  "subject_id",    limit: 4
    t.integer  "send_type",     limit: 4
    t.string   "subject_type",  limit: 255
    t.string   "title",         limit: 255
    t.text     "content",       limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "targets",       limit: 4
    t.datetime "start_time"
    t.integer  "status",        limit: 4
  end

  create_table "boom_playlists", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "mode",         limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "creator_id",   limit: 4
    t.string   "creator_type", limit: 255
    t.string   "cover",        limit: 255
    t.boolean  "removed",      limit: 1
    t.boolean  "is_top",       limit: 1
    t.boolean  "is_default",   limit: 1,   default: false
  end

  create_table "boom_recommends", force: :cascade do |t|
    t.string   "boom_id",      limit: 255
    t.string   "boom_type_id", limit: 255
    t.string   "boom_page_id", limit: 255
    t.string   "title",        limit: 255
    t.string   "subtitle",     limit: 255
    t.boolean  "removed",      limit: 1
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "boom_recommends", ["boom_id"], name: "index_boom_recommends_on_boom_id", using: :btree

  create_table "boom_tags", force: :cascade do |t|
    t.string   "boom_id",      limit: 255
    t.string   "name",         limit: 255
    t.boolean  "removed",      limit: 1
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.boolean  "is_hot",       limit: 1
    t.string   "lower_string", limit: 255
  end

  add_index "boom_tags", ["boom_id"], name: "index_boom_tags_on_boom_id", using: :btree

  create_table "boom_topics", force: :cascade do |t|
    t.string   "created_by",      limit: 255
    t.string   "avatar",          limit: 255
    t.string   "subject_type",    limit: 255
    t.integer  "subject_id",      limit: 4
    t.text     "content",         limit: 65535
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "collaborator_id", limit: 4
    t.boolean  "is_top",          limit: 1,     default: false
    t.string   "image",           limit: 255
    t.string   "video_title",     limit: 255
    t.string   "video_url",       limit: 255
  end

  create_table "boom_tracks", force: :cascade do |t|
    t.string   "boom_id",          limit: 255
    t.string   "boom_activity_id", limit: 255
    t.string   "name",             limit: 255
    t.string   "publisher",        limit: 255
    t.string   "file",             limit: 255
    t.decimal  "duration",                     precision: 12, scale: 6
    t.boolean  "removed",          limit: 1
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "boom_playlist_id", limit: 4
    t.integer  "creator_id",       limit: 4
    t.string   "creator_type",     limit: 255
    t.string   "artists",          limit: 255
    t.string   "cover",            limit: 255
    t.boolean  "is_top",           limit: 1
  end

  add_index "boom_tracks", ["boom_id"], name: "index_boom_tracks_on_boom_id", using: :btree

  create_table "boom_user_likes", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "subject_id",   limit: 4
    t.string   "subject_type", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "boom_user_message_relations", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "boom_message_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "boom_user_statuses", force: :cascade do |t|
    t.string   "boom_id",    limit: 255
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.integer  "value",      limit: 4
    t.boolean  "removed",    limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "boom_user_statuses", ["boom_id"], name: "index_boom_user_statuses_on_boom_id", using: :btree

  create_table "cities", force: :cascade do |t|
    t.string   "pinyin",     limit: 255
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.boolean  "is_hot",     limit: 1
  end

  create_table "collaborator_activity_relations", force: :cascade do |t|
    t.integer  "collaborator_id",  limit: 4
    t.integer  "boom_activity_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "collaborator_activity_relations", ["boom_activity_id"], name: "index_collaborator_activity_relations_on_boom_activity_id", using: :btree
  add_index "collaborator_activity_relations", ["collaborator_id"], name: "index_collaborator_activity_relations_on_collaborator_id", using: :btree

  create_table "collaborator_types", force: :cascade do |t|
    t.string   "boom_id",    limit: 255
    t.string   "code",       limit: 255
    t.string   "name",       limit: 255
    t.integer  "value",      limit: 4
    t.boolean  "removed",    limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "collaborator_types", ["boom_id"], name: "index_collaborator_types_on_boom_id", using: :btree

  create_table "collaborators", force: :cascade do |t|
    t.string   "boom_id",                   limit: 255
    t.string   "boom_collaborator_type_id", limit: 255
    t.string   "name",                      limit: 255
    t.string   "email",                     limit: 255
    t.string   "contact",                   limit: 255
    t.string   "weibo",                     limit: 255
    t.string   "cover",                     limit: 255
    t.string   "wechat",                    limit: 255
    t.text     "description",               limit: 65535
    t.boolean  "removed",                   limit: 1
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "verified",                  limit: 1,     default: false
    t.boolean  "is_top",                    limit: 1,     default: false
    t.string   "avatar",                    limit: 255
    t.integer  "identity",                  limit: 4
    t.string   "nickname",                  limit: 255
    t.integer  "sex",                       limit: 4
    t.datetime "birth"
    t.integer  "boom_admin_id",             limit: 4
    t.datetime "nickname_updated_at",                                     null: false
  end

  add_index "collaborators", ["boom_id"], name: "index_collaborators_on_boom_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "content",      limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "parent_id",    limit: 4
    t.integer  "topic_id",     limit: 4
    t.integer  "creator_id",   limit: 4
    t.string   "creator_type", limit: 255
  end

  create_table "common_data", force: :cascade do |t|
    t.string   "common_key",   limit: 255
    t.string   "common_value", limit: 255
    t.string   "remark",       limit: 255
    t.boolean  "is_block",     limit: 1,   default: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
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

  create_table "events", force: :cascade do |t|
    t.integer  "show_id",        limit: 4
    t.datetime "show_time"
    t.string   "stadium_map",    limit: 255
    t.string   "coordinate_map", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "events", ["show_id"], name: "index_events_on_show_id", using: :btree

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

  create_table "feedbacks", force: :cascade do |t|
    t.string   "content",    limit: 255
    t.string   "mobile",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "helps", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.integer  "position",    limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "message_tasks", force: :cascade do |t|
    t.integer  "boom_message_id", limit: 4
    t.string   "task_id",         limit: 255
    t.string   "platform",        limit: 255
    t.integer  "status",          limit: 4
    t.integer  "total_count",     limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "file_id",         limit: 255
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
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
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
    t.integer  "tickets_count",      limit: 4
    t.string   "refund_by",          limit: 255
    t.integer  "ticket_type",        limit: 4
    t.string   "ticket_info",        limit: 255
    t.decimal  "postage",                          precision: 4,  scale: 2, default: 0.0
  end

  add_index "orders", ["out_id"], name: "index_orders_on_out_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "page_cities", force: :cascade do |t|
    t.string   "boom_id",      limit: 255
    t.string   "boom_city_id", limit: 255
    t.boolean  "removed",      limit: 1
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "page_cities", ["boom_id"], name: "index_page_cities_on_boom_id", using: :btree

  create_table "page_city_activities", force: :cascade do |t|
    t.string   "boom_id",          limit: 255
    t.string   "boom_activity_id", limit: 255
    t.boolean  "removed",          limit: 1
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "page_city_activities", ["boom_id"], name: "index_page_city_activities_on_boom_id", using: :btree

  create_table "page_locations", force: :cascade do |t|
    t.string   "boom_id",           limit: 255
    t.string   "boom_music_top_id", limit: 255
    t.string   "boom_location_id",  limit: 255
    t.boolean  "removed",           limit: 1
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "page_locations", ["boom_id"], name: "index_page_locations_on_boom_id", using: :btree

  create_table "page_tag_hots", force: :cascade do |t|
    t.string   "boom_id",    limit: 255
    t.boolean  "removed",    limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "page_tag_hots", ["boom_id"], name: "index_page_tag_hots_on_boom_id", using: :btree

  create_table "page_tag_sorts", force: :cascade do |t|
    t.string   "boom_id",    limit: 255
    t.boolean  "removed",    limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "page_tag_sorts", ["boom_id"], name: "index_page_tag_sorts_on_boom_id", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

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

  create_table "playlist_track_relations", force: :cascade do |t|
    t.integer  "boom_track_id",    limit: 4
    t.integer  "boom_playlist_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "recommend_pages", force: :cascade do |t|
    t.string   "boom_id",        limit: 255
    t.integer  "visible_number", limit: 4
    t.boolean  "removed",        limit: 1
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "recommend_pages", ["boom_id"], name: "index_recommend_pages_on_boom_id", using: :btree

  create_table "recommend_types", force: :cascade do |t|
    t.string   "boom_id",    limit: 255
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.integer  "value",      limit: 4
    t.boolean  "removed",    limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "recommend_types", ["boom_id"], name: "index_recommend_types_on_boom_id", using: :btree

  create_table "show_area_relations", force: :cascade do |t|
    t.integer  "show_id",     limit: 4
    t.integer  "area_id",     limit: 4
    t.decimal  "price",                   precision: 6, scale: 2
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.boolean  "is_sold_out", limit: 1,                           default: false
    t.integer  "seats_count", limit: 4,                           default: 0
    t.string   "channels",    limit: 255
    t.integer  "left_seats",  limit: 4,                           default: 0
  end

  add_index "show_area_relations", ["show_id", "area_id"], name: "index_show_area_relations_on_show_id_and_area_id", using: :btree

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
    t.integer  "source",           limit: 4,                              default: 0
  end

  add_index "shows", ["city_id"], name: "index_shows_on_city_id", using: :btree
  add_index "shows", ["concert_id"], name: "index_shows_on_concert_id", using: :btree
  add_index "shows", ["stadium_id"], name: "index_shows_on_stadium_id", using: :btree

  create_table "simditor_images", force: :cascade do |t|
    t.string   "image",      limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "social_network_types", force: :cascade do |t|
    t.string   "boom_id",    limit: 255
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.integer  "value",      limit: 4
    t.boolean  "removed",    limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "social_network_types", ["boom_id"], name: "index_social_network_types_on_boom_id", using: :btree

  create_table "social_networks", force: :cascade do |t|
    t.string   "boom_id",      limit: 255
    t.string   "boom_type_id", limit: 255
    t.string   "boom_user_id", limit: 255
    t.string   "contact",      limit: 255
    t.boolean  "removed",      limit: 1
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "social_networks", ["boom_id"], name: "index_social_networks_on_boom_id", using: :btree

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
    t.string   "token",       limit: 255
  end

  add_index "stars", ["name"], name: "index_stars_on_name", using: :btree

  create_table "startups", force: :cascade do |t|
    t.string   "pic",        limit: 255
    t.datetime "valid_time"
    t.boolean  "is_display", limit: 1,   default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "tag_hots", force: :cascade do |t|
    t.string   "boom_id",      limit: 255
    t.string   "boom_page_id", limit: 255
    t.string   "name",         limit: 255
    t.boolean  "removed",      limit: 1
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "tag_hots", ["boom_id"], name: "index_tag_hots_on_boom_id", using: :btree

  create_table "tag_relationships", force: :cascade do |t|
    t.string   "boom_id",          limit: 255
    t.string   "boom_tag_id",      limit: 255
    t.string   "boom_tag_sort_id", limit: 255
    t.string   "boom_activity_id", limit: 255
    t.string   "boom_page_id",     limit: 255
    t.boolean  "removed",          limit: 1
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "tag_relationships", ["boom_id"], name: "index_tag_relationships_on_boom_id", using: :btree

  create_table "tag_sorts", force: :cascade do |t|
    t.string   "boom_id",      limit: 255
    t.string   "boom_page_id", limit: 255
    t.string   "name",         limit: 255
    t.boolean  "removed",      limit: 1
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "tag_sorts", ["boom_id"], name: "index_tag_sorts_on_boom_id", using: :btree

  create_table "tag_subject_relations", force: :cascade do |t|
    t.integer  "boom_tag_id",  limit: 4
    t.integer  "subject_id",   limit: 4
    t.string   "subject_type", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "area_id",         limit: 4
    t.integer  "show_id",         limit: 4
    t.decimal  "price",                       precision: 10, scale: 2
    t.integer  "order_id",        limit: 4
    t.string   "code",            limit: 255
    t.datetime "code_valid_time"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.integer  "status",          limit: 4,                            default: 0
    t.integer  "admin_id",        limit: 4
    t.datetime "checked_at"
    t.string   "seat_name",       limit: 255
    t.integer  "seat_type",       limit: 4,                            default: 0
    t.integer  "row",             limit: 4
    t.integer  "column",          limit: 4
    t.string   "channels",        limit: 255
  end

  add_index "tickets", ["area_id"], name: "index_tickets_on_area_id", using: :btree
  add_index "tickets", ["order_id"], name: "index_tickets_on_order_id", using: :btree
  add_index "tickets", ["seat_type", "status", "show_id", "area_id"], name: "index_tickets_on_seat_type_and_status_and_show_id_and_area_id", using: :btree
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

  create_table "user_follow_collaborators", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "collaborator_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "user_follow_collaborators", ["collaborator_id"], name: "index_user_follow_collaborators_on_collaborator_id", using: :btree
  add_index "user_follow_collaborators", ["user_id"], name: "index_user_follow_collaborators_on_user_id", using: :btree

  create_table "user_follow_concerts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "concert_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_follow_concerts", ["concert_id"], name: "index_user_follow_concerts_on_concert_id", using: :btree
  add_index "user_follow_concerts", ["user_id"], name: "index_user_follow_concerts_on_user_id", using: :btree

  create_table "user_follow_playlists", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "boom_playlist_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "user_follow_playlists", ["boom_playlist_id"], name: "index_user_follow_playlists_on_boom_playlist_id", using: :btree
  add_index "user_follow_playlists", ["user_id"], name: "index_user_follow_playlists_on_user_id", using: :btree

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

  create_table "user_track_relations", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "boom_track_id", limit: 4
    t.integer  "play_count",    limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "user_track_relations", ["boom_track_id"], name: "index_user_track_relations_on_boom_track_id", using: :btree
  add_index "user_track_relations", ["user_id"], name: "index_user_track_relations_on_user_id", using: :btree

  create_table "user_verified_info_types", force: :cascade do |t|
    t.string   "boom_id",    limit: 255
    t.string   "code",       limit: 255
    t.string   "name",       limit: 255
    t.integer  "value",      limit: 4
    t.boolean  "removed",    limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "user_verified_info_types", ["boom_id"], name: "index_user_verified_info_types_on_boom_id", using: :btree

  create_table "user_verified_infos", force: :cascade do |t|
    t.string   "boom_id",              limit: 255
    t.string   "boom_city_id",         limit: 255
    t.string   "boom_type_id",         limit: 255
    t.string   "name",                 limit: 255
    t.string   "name_english",         limit: 255
    t.string   "name_chinese",         limit: 255
    t.string   "phone",                limit: 255
    t.string   "address",              limit: 255
    t.string   "contact_name",         limit: 255
    t.string   "contact_phone_number", limit: 255
    t.string   "contact_address",      limit: 255
    t.text     "description",          limit: 65535
    t.decimal  "latitude",                           precision: 10, scale: 6
    t.decimal  "longitude",                          precision: 10, scale: 6
    t.string   "cover",                limit: 255
    t.string   "avatar",               limit: 255
    t.boolean  "removed",              limit: 1
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  add_index "user_verified_infos", ["boom_id"], name: "index_user_verified_infos_on_boom_id", using: :btree

  create_table "user_vote_concerts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "concert_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "city_id",    limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "mobile",                limit: 255
    t.string   "email",                 limit: 255
    t.string   "encrypted_password",    limit: 255
    t.datetime "last_sign_in_at"
    t.string   "avatar",                limit: 255
    t.string   "nickname",              limit: 255
    t.integer  "sex",                   limit: 4
    t.datetime "birthday"
    t.string   "salt",                  limit: 255
    t.boolean  "has_set_password",      limit: 1
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "api_token",             limit: 255
    t.integer  "api_expires_in",        limit: 4
    t.boolean  "is_block",              limit: 1,     default: false
    t.integer  "bike_user_id",          limit: 4
    t.integer  "channel",               limit: 4
    t.string   "boom_id",               limit: 255
    t.string   "boom_status_id",        limit: 255
    t.string   "boom_verified_info_id", limit: 255
    t.boolean  "removed",               limit: 1
    t.text     "description",           limit: 65535
  end

  add_index "users", ["bike_user_id"], name: "index_users_on_bike_user_id", using: :btree
  add_index "users", ["mobile"], name: "index_users_on_mobile", using: :btree

  create_table "videos", force: :cascade do |t|
    t.string   "url",        limit: 255
    t.integer  "star_id",    limit: 4
    t.integer  "concert_id", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "is_main",    limit: 1,   default: false
    t.string   "source",     limit: 255
    t.string   "snapshot",   limit: 255
    t.string   "star_token", limit: 255
  end

  add_index "videos", ["concert_id"], name: "index_videos_on_concert_id", using: :btree
  add_index "videos", ["star_id"], name: "index_videos_on_star_id", using: :btree

end
