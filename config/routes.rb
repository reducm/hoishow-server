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
          post "vote_a_concert" => "users#vote_a_concert"
        end
      end

      resources :stars
      resources :concerts do
        collection do
          get "get_all_object" => "concerts#get_all_object"
        end
      end
    end
  end
end
