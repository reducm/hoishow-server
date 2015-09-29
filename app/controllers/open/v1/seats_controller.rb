# encoding: utf-8
class Open::V1::SeatsController < Open::V1::ApplicationController
  def query_seats
    @seats = Seat.where(id: params[:seat_ids])
    not_found_respond if @seats.blank?
  end
end
