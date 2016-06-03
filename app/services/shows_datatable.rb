class ShowsDatatable
  delegate :params, :link_to, :content_tag, to: :@view

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
        is_upcoming(show),
        show.star_names,
        show.is_display_cn,
        show.is_presell_cn,
        show.source_cn,
        show.seat_type_cn,
        show.status_cn,
        show.ticket_type_cn,
        show.stadium.try(:name),
        wrap_text(show.event_show_time, '105px'),
        "#{tickets.sold_tickets.count}/#{show.total_seats_count}",
        control_link(show)
      ]
    end
  end

  def wrap_text(text, px)
    "#{content_tag(:p, text, style: "width: #{px}; word-wrap: break-word;") }"
  end

  def is_upcoming(show)
    if show.is_upcoming?
      "#{content_tag(:span, '即将到期', class: 'label label-danger')}" + " " + show.name
    else
      wrap_text(show.name, '300px')
    end
  end

  def control_link(show)
    "#{link_to '查看详情', "/operation/shows/#{show.id}", target: '_blank'} #{link_to '场次管理', "/operation/shows/#{show.id}/event_list", target: '_blank'} #{link_to '编辑', "/operation/shows/#{show.id}/edit", target: '_blank'} #{link_to (show.is_top ? '取消置顶' : '置顶'), "/operation/shows/#{show.id}/toggle_is_top", method: 'PATCH'}"
  end

  def shows
    @shows ||= fetch_shows
  end

  def shows_per_page
    #@shows_per_page ||= Kaminari.paginate_array(shows.to_a).page(page).per(10)
    @shows_per_page ||= shows.page(page).per(10)
  end

  def fetch_shows
    shows = Show.all
    # 搜演出或艺人名字
    if params[:search].present? && params[:search][:value].present?
      # 确保能按演出名称搜索
      shows = shows.eager_load(:concert => { :stars => :star_concert_relations })
                   .where("shows.name LIKE :search OR stars.name LIKE :search", search: "%#{params[:search][:value]}%")
                   .uniq
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
      shows = shows.where("shows.is_display = ?", params[:is_display])
    end
    # 按演出时间称过滤
    if params[:start_date].present? && params[:end_date].present?
      shows = shows.joins(:events).where("events.show_time between ? and ?", params[:start_date], params[:end_date])
    end
    # 按是否即将到期过滤
    if params[:is_upcoming].present?
      shows = params[:is_upcoming] == '1' ? shows.is_upcoming : shows.is_not_upcoming
    end
    # 按子分类过滤
    if params[:show_type].present?
      shows = shows.where("shows.show_type = ?", params[:show_type])
    end
    # 按价格范围过滤
    if params[:min_price].present?
      shows = shows.eager_load(:show_area_relations).where("show_area_relations.price > ?", params[:min_price].to_i)
    end
    if params[:max_price].present?
      shows = shows.eager_load(:show_area_relations).where("show_area_relations.price < ?", params[:max_price].to_i)
    end

    shows = shows.order(created_at: :desc)
  end

  def page
    params[:start].to_i/10 + 1
  end
end
