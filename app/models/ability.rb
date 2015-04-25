class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      cannot :manage, :all
    elsif user.class.to_s == "Admin"
      if user.admin?
        can :manage, :all
      elsif user.operator?
        # Star
        can :create, Star
        can :update, Star

        # Concert
        can :create, Concert
        can :update, Concert

        # Show
        can :create, Show
        can :update, Show

        # Topic
        can :create, Topic
        can :update, Topic

        # Comment
        can :create, Comment
        can :update, Comment

        # Stadium
        can :create, Stadium
        can :update, Stadium

        # Area
        can :create, Area
        can :update, Area

        basic_read_only
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

    can :read, User

    can :read, City

    can :read, Stadium
  end
end
