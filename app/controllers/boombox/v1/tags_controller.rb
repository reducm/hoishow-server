class Boombox::V1::TagsController < Boombox::V1::ApplicationController
  def hot_tags
    @tags = BoomTag.hot_tags.pluck(:name)

    render json: @tags
  end

  def search
    @records = BoomboxSearch.query_search(params[:keyword])
  end
end
