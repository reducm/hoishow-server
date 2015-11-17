# coding: utf-8
module Routes
  module BoomboxDjRoutes
    def self.draw(context)
      context.instance_eval do
        namespace :boombox do
          namespace :dj do
            root to: "home#index"

            resources :sessions, only: [:new, :create, :destroy]
            match "/signin" => "sessions#new", via: [:get]
            match "/signout" => "sessions#destroy", via: [:delete]

            resources :collaborators, only: [:edit, :update]

            resources :boom_albums, only: [:index, :create, :destroy] do
              member do
                post :set_cover
                post :unset_cover
              end
            end

            resources :boom_topics

            resources :boom_comments, only: [:index, :new, :create] 

            resources :tracks do
              collection do
                get :search
              end
            end

            resources :playlists do
              member do
                post :change_is_top
                get :manage_tracks
              end
              collection do
                get :search
              end
            end

            resources :boom_users, only: [:index, :show] do
              collection do
                get :search
              end
            end
          end
        end
      end
    end
  end
end
