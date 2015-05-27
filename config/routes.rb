#encoding: UTF-8
require 'sidekiq/web'
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "wxpay/notify" => "wxpay#notify"
      post "alipay/notify" => "alipay#notify"

      post "alipay/wireless_refund_notify" => "alipay#wireless_refund_notify"

      get 'orders/:out_id', :to => 'orders#show_for_qr_scan'

      get "express_detail" => "express_detail#index"

      resources :admins do
        collection do
          post "sign_in"
          patch "check_tickets"
        end
      end

      resources :users do
        collection do
          post "verification"
          post "sign_in"
          post "get_user" => "users#get_user"
          post "update_user" => "users#update_user"
          post "follow_subject" => "users#follow_subject"
          post "unfollow_subject" => "users#unfollow_subject"
          post "vote_concert" => "users#vote_concert"
          post "followed_stars" => "users#followed_stars"
          post "followed_shows" => "users#followed_shows"
          post "followed_concerts" => "users#followed_concerts"
          post "create_topic" => "users#create_topic"
          post "like_topic" => "users#like_topic"
          post "create_comment" => "users#create_comment"
          post "create_order" => "users#create_order"
        end
      end

      resources :banners

      resources :startup

      resources :stars do
        collection do
          get "search"
        end
      end
      resources :concerts do
        member do
          get "city_rank"
        end
      end
      resources :shows do
        member do
          get "preorder"
        end
      end
      resources :topics
      resources :comments
      resources :cities
      resources :stadiums
      resources :tickets
      resources :areas
      resources :orders, only: [:index, :show] do
        member do
          post :pay
        end
      end
    end
  end

  namespace :operation do
    root to: "home#index"
    mount Sidekiq::Web => '/sidekiq'
    resources :sessions, only: [:new, :create, :destroy]
    match "/signin" => "sessions#new", via: [:get]
    match "/signout" => "sessions#destroy", via: [:delete]

    resources :banners
    resources :videos do
      member do
        patch :set_main
      end
    end
    resources :stars do
      collection do
        post :sort
      end
      member do
        get :get_topics
      end
    end
    resources :concerts do
      member do
        get :get_city_topics
        get :get_city_voted_data
        get :get_cities
        post :add_concert_city
        get :refresh_map_data
        delete :remove_concert_city
      end
    end
    resources :shows do
      collection do
        get "get_city_stadiums"
      end
      member do
        post "update_area_data"
        post "update_status"
      end
    end
    resources :orders
    resources :users, only: [:index, :show] do
      member do
        post :block_user
        post :remove_avatar
      end
    end
    resources :admins, except: [:destroy] do
      member do
        post :block_admin
      end
    end
    resources :topics, only: [:create, :edit, :update] do
      member do
        get :refresh_comments
        post :add_comment
        delete :destroy_comment
        post :set_topic_top
      end
    end
    resources :tickets
    resources :messages
    resources :cities, only: [:index]
    resources :stadiums, except: [:show, :destroy] do
      member do
        get :refresh_areas
        post :submit_area
        delete :del_area
      end
    end
    resources :startup, except: [:new, :show, :edit] do
      member do
        post :set_startup_status
      end
    end
    #TODO api_auth
  end

  get "description", to: "description#show"
  get "express_detail", to: "express_detail#show"
end
