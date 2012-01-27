class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    can :create, Search
    can [:read,:update,:destroy], Search, :user_id => user.id
  end
end
