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
            get "/signup_resend_email" => 'pages#resend_email'
            # 完善资料
            match "/signup_fill_personal_form" => "collaborators#new", via: [:get]
            # 审核
            get "/signup_finished" => 'pages#after_create_collaborator'

            ## 忘记密码
            match "/forget_password" => "boom_admins#forget_password", via: [:get]
            get '/after_send_reset_password_email' => 'pages#after_send_reset_password_email'

            resources :sessions, only: [:new, :create, :destroy]
            match "/signin" => "sessions#new", via: [:get]
            match "/signout" => "sessions#destroy", via: [:delete]

            resources :boom_admins do
              member do
                get :confirm_email
                get :new_password
                post :reset_password
              end
              collection do
                get :forget_password
                post :send_reset_password_email
              end
            end

            resources :collaborators, only: [:new, :create, :edit, :update]

            resources :boom_albums, only: [:index, :create, :destroy] do
              member do
                post :toggle_cover
              end
            end

            resources :boom_topics, except: [:update, :new] do
              collection do
                post :create_attachment
                post :destroy_attachment
              end
            end

            resources :boom_comments, only: [:index, :new, :create] 

            resources :tracks do
              collection do
                get :search
              end
            end

            resources :playlists do
              member do
                post :add_track
                post :remove_track
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
