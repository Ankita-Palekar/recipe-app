class Recipe < ActiveRecord::Base
	belongs_to :user
	has_and_belongs_to_many :ingredients
	has_many :ratings, :dependent => :destroy
	#habtm should destroy row entries in the join table automatically it will not destroy from single ingredients or recipe table 
	
  attr_accessible :name, :image_links, :description, :meal_class, :total_calories, :aggregate_ratings, :serves, :approved

  

end
