# coding: utf-8
module Routes
  module OpenRoutes
    def self.draw(context)
      context.instance_eval do
        scope :api do
          namespace :open do
            namespace :v1 do
              # api about fetch and query info
              resources :cities, only: [:index]
              resources :stadiums, only: [:index, :show]
              resources :shows, only: [:index, :show]
              resources :areas, only: [:index, :show] do
                get :seats_info, on: :member
              end
              resources :events, only: [:index]
              # resources :seats, only: [:index, :show]
              get '/query_seats' => 'seats#query_seats'
              # api about orders
              resources :orders, only: [:create] do
                collection do
                  get :check_inventory
                  # use out_id to replace id for query
                  get ':out_id' => 'orders#show'
                  # post ':out_id/unlock_seat' => 'orders#unlock_seat'
                  post ':out_id/confirm' => 'orders#confirm'
                  post ':out_id/cancel_order' => 'orders#cancel_order'
                  post ':out_id/unlock_seat' => 'orders#unlock_seat'
                end
              end
            end
          end
        end
      end
    end
  end
end
