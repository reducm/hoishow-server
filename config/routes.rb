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
        end
      end

      resources :stars
      resources :concerts 
      resources :shows
    end
  end
end
