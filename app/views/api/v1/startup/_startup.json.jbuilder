# encoding: utf-8
json.id startup.id
json.pic startup.pic_url || ''
json.valid_time startup.valid_time.to_ms rescue nil
