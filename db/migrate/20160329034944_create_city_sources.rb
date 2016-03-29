class CreateCitySources < ActiveRecord::Migration
  def change
    create_table :city_sources do |t|
      t.string   "pinyin",        limit: 255
      t.string   "name",          limit: 255
      t.string   "code",          limit: 255
      t.datetime "created_at",                null: false
      t.datetime "updated_at",                null: false
      t.integer  "source",        limit: 4
      t.integer  "source_id",     limit: 4
      t.integer  "city_id",       limit: 4
      t.integer  "yl_fconfig_id", limit: 4

      t.timestamps null: false
    end
  end
end
