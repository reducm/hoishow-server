class PagesController < ApplicationController
  layout false

  # 帮助目录页
  def show_help
    @helps = Help.order(:position)
    render layout: 'mobile'
  end

  # 帮助下级页
  def show_sub_help
    # Help表的position相当于白名单
    # 如果地址合法而且有内容的话，返回内容
    position = request.path.split("/").last.to_i

    unless Help.pluck(:position).include?(position)
      render text: "not allow", status: 403
      return false
    end
    @help = Help.find_by_position!(position)
    @description = @help.description
    render layout: 'mobile'
  end

  def index
    @stars = Star.limit(4)
    render layout: 'application'
  end

  def about
  end

  def download
    @stars = Star.limit(4)
    render layout: 'mobile'
  end

  def app_download
    redirect_to 'http://a.app.qq.com/o/simple.jsp?pkgname=us.bestapp.hoishow'
  end

  def wap_index
  end

  def wap_about
  end

  def sharing_show
    @show = Show.find_by_id(params[:show_id])
    render layout: 'mobile'
  end

  def sharing_concert
    @concert = Concert.find_by_id(params[:concert_id])
    cities = @concert.cities
    result ||= []
    cities.each do |city|
      hash = city.attributes
      hash.merge!({"vote_count" => UserVoteConcert.where(concert_id: @concert.id, city_id: city.id).count + @concert.concert_city_relations.find_by_city_id(city.id).try(:base_number).to_i})
      result.push(hash)
    end
    #sort
    result = result.sort!{|x, y| x["vote_count"] <=> y["vote_count"]}.reverse
    @cities = result[0..9]
    render layout: 'mobile'
  end
end
