# coding: utf-8
module Routes
  module BoomboxRoutes
    def self.draw(context)
      context.instance_eval do
        scope :api do
          namespace :boombox do
            namespace :v1 do
              # api about fetch and query info
              resources :banners, only: :index
              resources :collaborators, only: [:index, :show]
            end
          end
        end
      end
    end
  end
end
