class ChangeOldSeatsToSeatsInfo < ActiveRecord::Migration
  def up
    # 将所有选座的演出的座位更新到 area 的 seats info 里面
    Area.transaction do
      shows = Show.where(seat_type: Show.seat_types[:selectable]).all

      shows.each do |s|
        relations = ShowAreaRelation.where(show_id: s.id).all

        relations.each do |sar|
          area = sar.area
          seats = area.seats
          p "before seats count ----> #{seats.size}"
          p "area_id ----> #{area.id}"

          if !seats.blank?
            # load area info
            max_row = area.seats.maximum('row')
            max_col = area.seats.maximum('column')
            sort_by = area.sort_by
            # set seats_info

            seats_info = {}
            seats_info['total'] = [max_row, max_col].join('|')
            seats_info['sort_by'] = sort_by
            seats_info['selled'] = []
            seats_info['seats'] = {}

            seats.each do |st|
              key = [st.row, st.column].join('|')
              # 将已经卖出去的票加入到 已售列表
              if st.status == 'locked' && st.order_id != nil
                seats_info['selled'] << key
              end

              seats_info['seats'][key] = { status: st.status, price: st.price,
                channels: st.channels, seat_no: st.name }
            end
            p "seat_info ----> #{seats_info}"
            p "after seats count ----> #{seats_info['seats'].size}"
            p "------------next------------"

            area.update_attributes! seats_info: seats_info
          end
        end
      end
    end
  end
end
