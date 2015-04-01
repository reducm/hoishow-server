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
          post "vote_concert" => "users#vote_concert"
          post "followed_stars" => "users#followed_stars"
          post "followed_concerts" => "users#followed_concerts"
          post "create_topic" => "users#create_topic"
        end
      end

      resources :stars do
        collection do
          get "search"
        end
      end
      resources :concerts 
      resources :shows
    end
  end
end
