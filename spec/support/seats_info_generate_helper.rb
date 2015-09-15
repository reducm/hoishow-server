module SeatsInfoGenerateHelper
  def generate_seats(max_row, max_col, status, channels=[], asc=true, selled_seats=[])
    seats_info = {}
    column_array = asc ? 1.upto(max_col) : max_col.downto(1)
    price = rand(100..300)

    1.upto(max_row) do |row|
      column_array.each do |col|
        seats_info["#{[row, col].join('|')}"] = { status: status,
          price: price, channels: channels, seat_no: "#{row}排#{col}座" }
      end
    end

    return {}.tap do |h|
      h["seats"] = seats_info
      h["sort_by"] = asc ? 'asc' : 'desc'
      h['total'] = [max_row, max_col].join('|')
      h['selled'] = selled_seats
    end
  end
end
