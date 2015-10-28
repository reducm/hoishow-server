# coding: utf-8
module Routes
  module BoomboxRoutes
    def self.draw(context)
      context.instance_eval do
        scope :api do
          namespace :boombox do
            namespace :v1 do
              # api about fetch and query info
              resources :banners, only: :index
              resources :users do
                collection do
                  get "verification"
                  get "verified_mobile"
                  post "sign_up"
                  post "sign_in"
                  post "forgot_password"
                  post "reset_password"
                  post "update_user"
                  post "reset_mobile"
                  get "get_user"
                  get "followed_collaborators"
                  get "followed_playlists"
                  get "my_playlists"
                  get "comment_list"
                  get "message_list"
                  post "follow_subject"
                  post "create_comment"
                  post "like_subject"
                  post "add_or_remove_track_belong_to_playlist"
                  post "add_or_remove_playlist"
                  post "listened"
                end
              end
              resources :collaborators, only: [:index, :show] do
                member do
                  get :timeline
                  get :comments
                  get :playlists
                  get :tracks
                  get :shows
                end
              end
              resources :activities, only: [:index, :show]
              resources :tracks, only: [:index, :show]
              resources :playlists, only: [:show]

              get '/recommend' => 'home#index'

              get '/radios' => 'playlists#radio_list'
              get '/playlists' => 'playlists#playlist_list'

              get '/hot_tags' => 'tags#hot_tags'
              get '/search' => 'tags#search'
            end
          end
        end
      end
    end
  end
end
