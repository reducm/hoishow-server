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
          post "followed_concerts" => "users#followed_concerts"
          post "create_topic" => "users#create_topic"
          post "like_topic" => "users#like_topic"
          post "create_comment" => "users#create_comment"
          post "create_order" => "users#create_order"
        end
      end

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
      resources :orders, only: [:index, :show]
    end
  end

  namespace :operation do
    root to: "home#index"
    mount Sidekiq::Web => '/sidekiq'
    resources :sessions, only: [:new, :create, :destroy]
    match "/signin" => "sessions#new", via: [:get]
    match "/signout" => "sessions#destroy", via: [:delete]
    resources :stars do
      collection do
        post :sort
      end
    end
    resources :concerts do
      member do
        get :get_city_topics
        get :get_city_voted_data
        post :add_concert_city
        get :refresh_map_data
        delete :remove_concert_city
      end
    end
    resources :shows
    resources :orders
    resources :users
    resources :admins
    resources :topics, only: [:new, :create, :show]
    #TODO api_auth
  end
end
