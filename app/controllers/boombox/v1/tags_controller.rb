class Boombox::V1::TagsController < ApplicationController
  def hot_tags
    @tags = BoomTag.hot_tags.pluck(:name)

    render json: @tags
  end

  def search
    @tag = BoomTag.where(name: params[:keyword]).first
  end
end
