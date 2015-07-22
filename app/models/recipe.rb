require 'static_data.rb'
class Recipe < ActiveRecord::Base
	belongs_to :user
	has_and_belongs_to_many :ingredients
	has_many :ratings, :dependent => :destroy
	#habtm should destroy row entries in the join table automatically it will not destroy from single ingredients or recipe table 
	
  attr_accessible :name, :image_links, :description, :meal_class, :total_calories, :aggregate_ratings, :serves, :approved

  validates :name, :presence => true
  validates :description, :presence => true
  validates :meal_class, :inclusion => {:in => StaticData::MEAL_CLASS, :message => "meal_class can only contain jain, veg, non-veg"}
  validates :serves, :numericality => true
  validates :aggregate_ratings, :numericality => true


  #recipe = Recipe.new
 
  #params = [:name=>"", :image_links=>"", :desciption => "", :meal_class => "", :total_calories, :aggregate_ratings => "", :serves => "", :approved => "", :ingredients=>[{:name=> "", :meal_class => "", std_measurement => "", std_quantity => "", calories_per_quantity => ""},{:name=> "", :meal_class => "", std_measurement => "", std_quantity => "", calories_per_quantity => ""},]]
  #recipe.create_recipe(params)
  
  def create_recipe(params:)
  	# Recipe.transaction do
  	# 	begin	
	  # 		#save ingredients first using create_ingredients function 
	  # 		#get least strict ingredient class name
	  # 		#set class name to recipe 
	  # 		#recipe.save!
	  # 		#save recipe ingredient in join table ingredients_recipes
	  # 	rescue ActiveRecord::RecordNotSaved
  	# 	  #error messages
  	# 	end
  	# end
  end

  #call Recipe.show_pending_recipes
  def self.show_pending_recipes
    # Recipe.where(approved: false)  
  end

  # REVIEW: naming. What is 'accept' supposed to mean? Why is the naming of
  # this function not consistent with Ingredient#ingredient_accept? Pick one
  # naming convention and stick to it. Either approve_x or x_approve
  def accept_recipe
    # @approved = true
    # save
    # user = User.find_by_id(recipe.user_id)
    # user.send_email_notification_recipe_accepted
  end

  # REVIEW: inconsitent naming. Is this recipe type or recipe meal class?
  def self.get_recipe_type(ingredients_list:)
  	# depending upon the least strict meal class of ingredients
  end
end
