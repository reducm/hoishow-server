# coding: utf-8
module Routes
  module BoomboxDjRoutes
    def self.draw(context)
      context.instance_eval do
        namespace :boombox do
          namespace :dj do
            root to: "home#index"

            ## 注册步骤
            # 注册
            match "/signup" => "boom_admins#new", via: [:get]
            # 发送验证邮件
            get "/signup_send_email" => 'pages#after_create_boom_admin'
            # 完善资料
            match "/signup_fill_personal_form" => "collaborators#new", via: [:get]
            # 审核
            get "/signup_finished" => 'pages#after_create_collaborator'

            resources :sessions, only: [:new, :create, :destroy]
            match "/signin" => "sessions#new", via: [:get]
            match "/signout" => "sessions#destroy", via: [:delete]

            resources :boom_admins do
              member do
                get :confirm_email
              end
            end

            resources :collaborators, only: [:new, :create, :edit, :update]

            resources :boom_albums, only: [:index, :create, :destroy] do
              member do
                post :set_cover
                post :unset_cover
              end
            end

            resources :boom_topics, except: [:update, :new]

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
