# coding: utf-8
module Routes
  module BoomboxOperationRoutes
    def self.draw(context)
      context.instance_eval do
        namespace :boombox do
          namespace :operation do
            root to: "home#index"
            match "/home/get_users_data" => "home#get_users_data", via: [:get]

            resources :sessions, only: [:new, :create, :destroy]
            match "/signin" => "sessions#new", via: [:get]
            match "/signout" => "sessions#destroy", via: [:delete]

            resources :collaborators, except: [:new, :create, :destroy] do
              member do
                post :toggle_is_top
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
                post :toggle_is_top
              end
            end

            resources :boom_comments, only: :index do
              member do
                post :hide
              end
            end

            resources :tracks do
              post :convert_audio_notify, on: :collection
              post :change_is_top, on: :member
            end

            resources :playlists do
              member do
                post :add_track
                post :remove_track
                get :manage_tracks
                post :publish
                post :change_is_top
              end
            end

            resources :radios do
              member do
                post :add_track
                post :remove_track
                get :manage_tracks
                post :publish
                post :change_is_top
              end
            end

            resources :activities do
              member do
                post :change_is_top
                post :change_is_hot
                patch :upload_cover
              end

              post :upload_image, on: :collection
            end

            resources :news, except: [:show, :destroy] do
              member do
                post :toggle_is_top
              end
            end

            resources :boom_tags, only: [:index, :create, :destroy] do
              member do
                post :change_is_hot
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
            end

            resources :boom_users, only: [:index, :show] do
              member do
                post :block_user
                post :block_comment
                post :remove_avatar
              end
            end

            resources :boom_banners do
              collection do
                post :sort
              end
            end

            resources :messages, only: [:index, :new, :create] do
              post :push_again, on: :member
            end
          end
        end
      end
    end
  end
end
