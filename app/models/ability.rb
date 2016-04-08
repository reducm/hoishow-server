# encoding: utf-8
class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      cannot :manage, :all
    # hoishow权限
    # 由于hoishow user controller传过来的只有hoishow的用户
    # 所以hoishow运营人员不会看到播霸的用户
    # 但hoishow后台别的地方用到User表的话还是要过滤一下，User.from_hoishow
    elsif user.class.to_s == "Admin"
      if user.admin?
        can :manage, Area
        can :manage, Banner
        can :manage, City
        can :manage, Comment
        can :manage, Concert
        can :manage, Message
        can :manage, Order
        can :manage, Show
        can :manage, Star
        can :manage, Stadium
        can :manage, Startup
        can :manage, Ticket
        can :manage, Topic
        can :manage, User, boom_id: nil
        can :manage, Admin
        can :manage, Feedback
        can :manage, CommonData

        can :set_channels
      elsif user.operator?
        # Star
        can :create, Star
        can :update, Star
        # Show
        can :create, Show
        can :update, Show
        # Stadium
        can :manage, Stadium
        # Area
        can :create, Area
        can :update, Area
        # Order
        can :update, Order
        # SiteSetting
        can :manage, CommonData
        # City
        can :manage, City

        basic_read_only
      end
    # 播霸权限
    elsif user.class.to_s == "BoomAdmin"
      if user.admin? || user.operator?
        # 后台需要的模块加这里
        can :manage, Collaborator
        can :manage, BoomAlbum
        can :manage, BoomTopic
        can :manage, BoomComment
        can :manage, User
      end
    else
      #TODO
    end
  end

  protected

  def basic_read_only
    can :read, Star
    can :read, Concert
    can :read, Show
    can :read, Order
    can :read, Ticket
    can :read, User, boom_id: nil
    can :read, City
    can :read, Stadium
    can :read, Topic
    can :read, Comment
    can :read, Message
    can :read, Startup
    can :read, Banner
    can :read, Feedback
  end
end
