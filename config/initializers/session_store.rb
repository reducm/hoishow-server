# Be sure to restart your server when you modify this file.

memcache_host = Rails.env.production? ? '10.6.21.209' : '127.0.0.1'

require 'action_dispatch/middleware/session/dalli_store'
Rails.application.config.session_store :dalli_store, :memcache_server => [memcache_host], :namespace => 'hoishow:session', :key => '_session_id', :expire_after => 5.days
