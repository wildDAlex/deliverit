class Ability
  include CanCan::Ability

  def initialize(user)


    user ||= User.new # guest user (not logged in)
    cannot :manage, :all
    can :read, Share, public: true
    can :show_by_name, Share, public: true
    can :download, Share, public: true

    if user.admin?
      can :manage, :all
    end

    if user.registered?
      can :manage, Share, user_id: user.id
      can :create, Share
      can :read, Share, public: true
      can :show_by_name, Share, public: true
    end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
