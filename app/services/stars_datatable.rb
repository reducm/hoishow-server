class StarsDatatable
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

# dataTable需要的参数
  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: Star.count,
      recordsFiltered: stars.size,
      data: data
    }
  end

private

  def data
    stars_per_page.map do |star|
      [
        star.id,
        "#{image_tag(star.avatar_url, size: '50x50') if star.avatar_url}",
        star.name,
        star.is_display_cn,
        star.status_cn,
        star.vote_count,
        star.followers_count,
        control_link(star)
      ]
    end
  end

  def control_link(star)
    "#{link_to "编辑", "/operation/stars/#{star.id}/edit"} #{link_to "查看详情", "/operation/stars/#{star.id}"}"
  end

  def stars
    @stars ||= fetch_stars
  end

  def stars_per_page
    @stars_per_page ||= Kaminari.paginate_array(stars.to_a).page(page).per(10)
  end

  def fetch_stars
    stars = Star.order(created_at: :desc)
    # 搜艺人名字
    if params[:search].present? && params[:search][:value].present?
      stars = stars.where("stars.name like :search", search: "%#{params[:search][:value]}%")
    end
    # 按状态过滤 {"开售中"=>1, "无演出"=>0}
    if params[:status].present?
      stars = if params[:status].to_i == 0
                stars.select{|s| s.shows.blank?}
              elsif params[:status].to_i == 1
                stars.select{|s| s.shows.any?}
              end
    end
    stars
  end

  def page
    params[:start].to_i/10 + 1
  end
end
