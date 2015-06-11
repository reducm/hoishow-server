# encoding: utf-8
class Operation::HomeController < Operation::ApplicationController
  before_filter :check_login!

  def index
    @concerts = Concert.concerts_without_auto_hide.order('created_at DESC').limit(10)
    @shows = Show.where("status = 0").order("created_at desc").limit(10)
    @topics = Topic.order("created_at desc").limit(10)
    @comments = Comment.order("created_at desc").limit(10)
  end
end
