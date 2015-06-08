#encoding: UTF-8
class Area < ActiveRecord::Base
  belongs_to :stadium

  has_many :show_area_relations
  has_many :shows, through: :show_area_relations
  has_many :tickets
  has_many :seats

  validates :stadium, presence: {message: "场馆不能为空"}

  paginates_per 10

  def seats_info(show_id)
    rowId = 0
    seat = seats.where(show_id: show_id).first
    seats_info = []
    if seat
      seats_info = JSON.parse seat.seats_info
      seats_info = seats_info['rows'].map do |row|
        rowId += 1
        if seats_info['sort_by'] == 'asc'
          columnId = 0
        elsif seats_info['sort_by'] == 'desc'
          columnId = row.select{|s| s['seat_status'] != 'unused'}.size + 1
        end
        row.map do |seat|
          if seat['seat_status'] != 'unused'
            if seats_info['sort_by'] == 'asc'
              columnId += 1
            elsif seats_info['sort_by'] == 'desc'
              columnId -= 1
            end
            if seat['seat_no'].blank?
              {
                row: seat['row'],
                column: seat['column'],
                seat_no: "#{rowId}排#{columnId}座",
                status: seat['seat_status'],
                price: seat['price'],
                sort_by: seats_info['sort_by']
              }
            else
              {
                row: seat['row'],
                column: seat['column'],
                seat_no: seat['seat_no'],
                status: seat['seat_status'],
                price: seat['price'],
                sort_by: seats_info['sort_by']
              }
            end
          else
            {
              row: seat['row'],
              column: seat['column'],
              status: seat['seat_status'],
              sort_by: seats_info['sort_by']
            }
          end
        end
      end
    end
  end
end
