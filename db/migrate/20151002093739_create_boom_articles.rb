class CreateBoomArticles < ActiveRecord::Migration
  def change
    create_table :boom_articles do |t|
      t.string :boom_id
      t.string :boom_location_id
      t.string :title
      t.string :subtitle
      t.string :url_alias
      t.string :url_short
      t.string :url_origin
      t.string :cover
      t.string :summary
      t.text :content_html
      t.text :content_json
      t.boolean :verified
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_articles, :boom_id

    File.open(File.join(Rails.root, 'db', 'boombox', 'article.json'), 'r') do |file|
      BoomArticle.transaction do
        file.each do |line|
          a_json = JSON.parse line
          location_id = a_json['location'].blank? ? '' : a_json['location'][0]['$oid']
          BoomArticle.create(
            boom_id: a_json['_id']['$oid'],
            boom_location_id: location_id,
            title: a_json['title'],
            subtitle: a_json['subtitle'],
            url_alias: a_json['url_alias'],
            url_short: a_json['url_short'],
            url_origin: a_json['url_origin'],
            cover: a_json['cover'],
            summary: a_json['summary'],
            content_html: a_json['content_html'],
            content_json: a_json['content_json'],
            verified: a_json['verified'],
            removed: a_json['removed'],
            created_at: a_json['date_creation']['$date'].to_time
          )
        end
      end
    end if Rails.env.production? || Rails.env.staging?
  end
end
