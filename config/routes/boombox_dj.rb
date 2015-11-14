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

            resources :collaborators, except: [:new, :create, :destroy] do
              member do
                post :set_top
                post :verify
              end
            end

            resources :boom_albums, only: [:index, :create, :destroy] do
              member do
                post :set_cover
                post :unset_cover
              end
            end

            resources :boom_topics, only: [:index, :show, :destroy] do
              member do
                post :set_top
              end
            end

            resources :boom_comments, only: :index do
              member do
                post :hide
              end
            end

            resources :tracks do
              member do
                post :change_is_top
              end
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

            resources :radios do
              member do
                post :change_is_top
              end
              collection do
                get :search
              end
            end

            resources :activities do
              member do
                post :change_is_top
              end
              collection do
                get :search
              end
            end

            resources :boom_tags, only: [:index, :create, :destroy] do
              member do
                post :change_is_top
              end
              collection do
                get :search
              end
            end

            resources :boom_admins do
              member do
                post :block_admin
              end
            end

            resources :boom_feedbacks, only: [:index] do
              member do
                post :update_status
              end
              collection do
                get :search
              end
            end

            resources :boom_users, only: [:index, :show] do
              member do
                post :block_user
              end
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
