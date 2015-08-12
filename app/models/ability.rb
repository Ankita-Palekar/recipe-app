class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new # guest user (not logged in)
    # alias_action :new, :rate_recipe, :my_pending_recipes, :my_rejected_recipes, :my_top_rated_recipes, :my_most_rated_recipes, :my_approved_recipes, :create, :index,  :to => :user_functionality
    # alias_action :search, :search_recipes, :rated_users, :top_rated_recipes, :most_rated_recipes, :to => :public_functionality
    if user.is? :admin
      can :manage, :all 
    elsif user.is? :user
      can :manage, Recipe, :creator_id => user.id
    else 
      can :public_functionality, Recipe  
    end
  end
end


