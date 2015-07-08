#encoding: UTF-8
require 'sidekiq/web'
Rails.application.routes.draw do
  root to: 'pages#index'
  get "/about" => 'pages#about'

  get "/mobile" => 'pages#wap_index'
  get "/mobile/about" => 'pages#wap_about'

  #app下载
  get "/mobile/download" => 'pages#download'
  get '/app/download', to: 'pages#app_download'

  #分享页
  get "/mobile/shows/sharing" => "pages#sharing_show"
  get "/mobile/concerts/sharing" => "pages#sharing_concert"

  namespace :api do
    namespace :open do
      namespace :v1 do
        resources :cities, only: [:index]
      end
    end

    namespace :v1 do
      post "wxpay/notify" => "wxpay#notify"
      post "alipay/notify" => "alipay#notify"

      post "alipay/wireless_refund_notify" => "alipay#wireless_refund_notify"

      get "express_detail" => "express_detail#index"

      resources :admins do
        collection do
          post "sign_in"
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
          post "update_express_info" => "users#update_express_info"
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
          get "seats_info"
          get "click_seat"
        end
      end
      resources :topics
      resources :comments
      resources :cities
      resources :stadiums
      resources :messages
      resources :tickets do
        collection do
          post :check_tickets
          get :get_ticket
        end
      end
      resources :areas
      resources :orders, only: [:index, :show] do
        collection do
          get :orders_for_soon
        end
        member do
          post :pay
          get :show_for_qr_scan
        end
      end
    end
  end

  namespace :operation do
    root to: "home#index"
    match "/home/get_graphic_data" => "home#get_graphic_data", via: [:get]
    mount Sidekiq::Web => '/sidekiq'
    resources :sessions, only: [:new, :create, :destroy]
    match "/signin" => "sessions#new", via: [:get]
    match "/signout" => "sessions#destroy", via: [:delete]

    resources :banners do
      collection do
        post :sort
      end
    end
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
        post :new_show
      end
    end
    resources :concerts do
      member do
        get :get_city_topics
        get :get_city_voted_data
        get :get_cities
        post :add_concert_city
        post :update_base_number
        post :add_star
        delete :remove_star
        get :refresh_map_data
        delete :remove_concert_city
        patch :toggle_is_top
        post :send_create_message
      end
      collection do
        get :search
      end
    end
    resources :shows do
      collection do
        get "get_city_stadiums"
        get :search
      end
      member do
        post "update_area_data"
        post "update_mode"
        patch :toggle_is_top
        post :new_area
        delete :del_area
        get :seats_info
        post :update_seats_info
        post :send_create_message
        post :add_star
        delete :del_star
        post :set_area_channels
      end
    end
    resources :orders do
      member do
        post "update_express_id"
        post "update_remark_content"
      end
      collection do
        get :search
        get :search_express
      end
    end
    resources :users, only: [:index, :show] do
      member do
        post :block_user
        post :remove_avatar
      end
      collection do
        get :search
      end
    end
    resources :admins, except: [:destroy] do
      member do
        post :block_admin
      end
    end
    resources :topics, only: [:create, :edit, :update, :index] do
      member do
        get :refresh_comments
        post :add_comment
        delete :destroy_comment
        delete :destroy_topic
        post :set_topic_top
        post :update_topic_is_top
      end
    end
    resources :tickets do
      collection do
        get :search
      end
    end
    resources :messages do
      member do
        post :send_umeng_message_again
      end
    end
    resources :comments
    resources :cities, only: [:index] do
      collection do
        get :search
      end
    end
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
  get "seats_map", to: "seats_map#show"

  #simditor_image
  post '/simditor_image', to: 'simditor_image#upload'
end
