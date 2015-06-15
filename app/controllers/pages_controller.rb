class PagesController < ApplicationController
  layout false

  def index
    render layout: 'application'
  end

  def about
  end

  def download
    @stars = Star.limit(4)
    render layout: 'mobile'
  end

  def app_download
    #TODO 等待注册应用宝生成链接
    redirect_to ''
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
