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
              resources :collaborators, only: [:index, :show] do
                member do
                  get :timeline
                  get :comments
                  get :playlists
                  get :tracks
                  get :shows
                end
              end

              get '/radios' => 'playlists#radio_list'
              get '/playlists' => 'playlists#playlist_list'
            end
          end
        end
      end
    end
  end
end
