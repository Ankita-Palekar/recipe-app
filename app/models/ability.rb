class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.is? :admin
      can :manage, :all 
    elsif user.is? :user
      can :manage, Recipe, :creator_id => user.id
      can :manage, User, :id => user.id
    else 
      can :public_functionality, Recipe  
       
    end
  end
end


