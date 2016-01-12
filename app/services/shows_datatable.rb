class ShowsDatatable
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

# dataTable需要的参数
  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: Show.count,
      recordsFiltered: shows.size,
      data: data
    }
  end

private

  def data
    shows_per_page.map do |show|
      tickets = show.tickets
      [
        show.star_names,
        show.name,
        show.is_display_cn,
        show.is_presell_cn,
        show.source_cn,
        show.seat_type_cn,
        show.status_cn,
        show.ticket_type_cn,
        show.stadium.try(:name),
        show.event_show_time,
        "#{tickets.sold_tickets.count}/#{show.total_seats_count}",
        control_link(show)
      ]
    end
  end

  def control_link(show)
    "#{link_to '查看详情', "/operation/shows/#{show.id}"} #{link_to '场次管理', "/operation/shows/#{show.id}/event_list"} #{link_to '编辑', "/operation/shows/#{show.id}/edit"} #{link_to (show.is_top ? '取消置顶' : '置顶'), "/operation/shows/#{show.id}/toggle_is_top", method: 'PATCH'}"
  end

  def shows
    @shows ||= fetch_shows
  end

  def shows_per_page
    @shows_per_page ||= Kaminari.paginate_array(shows.to_a).page(page).per(10)
  end

  def fetch_shows
    shows = Show.order(created_at: :desc)
    # 搜演出和艺人名字
    if params[:search].present? && params[:search][:value].present?
      shows = shows.where("shows.name like :search", search: "%#{params[:search][:value]}%")
    end
    # 按购票状态过滤
    if params[:status].present?
      shows = shows.where("shows.status = ?", params[:status])
    end
    # 按演出来源过滤
    if params[:source].present?
      shows = shows.where("shows.source = ?", params[:source])
    end
    # 按显示状态过滤
    if params[:is_display].present?
      shows = shows.where("shows.is_display = ?", params[:buy_origin])
    end
    # 按演出时间称过滤
    if params[:start_date].present? && params[:end_date].present?
      shows = shows.joins(:events).where("events.show_time between ? and ?", params[:start_date], params[:end_date])
    end
    shows
  end

  def page
    params[:start].to_i/10 + 1
  end
end
