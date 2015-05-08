#encoding: UTF-8
require 'sidekiq/web'
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
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
      resources :orders, only: [:index, :show]
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
        post "update_is_show"
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
    resources :cities, only: [:index]
    resources :stadiums, except: [:show, :destroy] do
      member do
        get :refresh_areas
        post :submit_area
        delete :del_area
      end
    end
    #TODO api_auth
  end

  get "description", to: "description#show"
end
