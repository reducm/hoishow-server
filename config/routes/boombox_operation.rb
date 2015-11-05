# coding: utf-8
module Routes
  module BoomboxOperationRoutes
    def self.draw(context)
      context.instance_eval do
        namespace :boombox do
          namespace :operation do
            root to: "home#index"

            resources :sessions, only: [:new, :create, :destroy]
            match "/signin" => "sessions#new", via: [:get]
            match "/signout" => "sessions#destroy", via: [:delete]

            resources :collaborators, except: [:new, :create, :destroy] do
              member do
                post :set_top
                post :verify
              end
            end

            resources :boom_albums, only: [:index, :create, :destroy] do
              member do
                post :set_cover
              end
            end

            resources :boom_topics, only: [:index, :show, :destroy]

          end
        end
      end
    end
  end
end
