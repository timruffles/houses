class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    alias_action :mine, :to => :see_my_own
    alias_action :me, :to => :see_myself
    can(:create, Search) { !user.new_record? }
    can [:see_my_own,:read,:update,:destroy], Search, :user_id => user.id
    can [:update], ClassifiedTweet, :user_id => user.id
    can [:see_myself], User
  end
end
