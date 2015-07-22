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

end
