# coding: utf-8
module Routes
  module BoomboxOperationRoutes
    def self.draw(context)
      context.instance_eval do
        namespace :boombox do
          namespace :operation do
            root to: "home#index"

            resources :sessions, only: [:new, :create, :destroy]
            match "/signin" => "sessions#new", via: [:get]
            match "/signout" => "sessions#destroy", via: [:delete]

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
