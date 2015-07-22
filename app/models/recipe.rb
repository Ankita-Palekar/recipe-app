class Recipe < ActiveRecord::Base
	belongs_to :user
	has_and_belongs_to_many :ingredients
	has_many :ratings, :dependent => :destroy
	#habtm should destroy row entries in the join table automatically it will not destroy from single ingredients or recipe table 
	
  attr_accessible :name, :image_links, :description, :meal_class, :total_calories, :aggregate_ratings, :serves, :approved
  validates :name, :presence => true
  validates :description, :presence => true
  validates :meal_class, :inclusion => {:in => ["jain", "veg", "non-veg"], :message => "meal_class can only contain jain, veg, non-veg"}
  validates :serves, :numericality => true
  validates :aggregate_ratings, :numericality => true

  def create_recipe
  	Recipe.transaction do
  		begin	
	  		#save ingredients first using create_ingredients function 
	  		#get least strict ingredient class name
	  		#set class name to recipe 
	  		#recipe.save!
	  		#save recipe ingredient in join table ingredients_recipes
	  	rescue ActiveRecord::RecordNotSaved
  		 #error messages
  		end
  	end
  end

  def show_pending_recipes
    
  end

  def accept_recipe(:recipe_id)
    #make approved flag true, send mail to recipe owner
  end

  def get_recipe_type
  	# depending upon the least strict meal class of ingredients
  end
end
