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

            resources :collaborators, except: :destroy
          end
        end
      end
    end
  end
end
