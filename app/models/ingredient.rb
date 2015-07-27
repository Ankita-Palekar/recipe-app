class Ingredient < ActiveRecord::Base
	# has_and_belongs_to_many :recipes
	belongs_to :user
	has_many :recipe_ingredients
	has_many :recipes, :through => :recipe_ingredients #change naming otherwise @@SCREWED


  attr_accessible :name, :meal_class, :std_measurement, :std_quantity, :calories_per_quantity, :approved, :creator_id
	MEAL_CLASS = %w(non-veg veg jain)
	STD_QUANTITY = ["teaspoon", "tablespoon", "fluid ounce", "gill", "cup", "pint", "quart", "gallon", "ml", "l", "dl", "pounds", "ounce", "mg", "g", "kg", "mm", "cm", "m", "inch"]
	
  validates :name, :presence => true
  validates :meal_class, :inclusion => {:in => MEAL_CLASS, :message => "meal_class can only contain jain, veg, non-veg"}
  validates :std_measurement, :inclusion => {:in => STD_QUANTITY, :message => "invalid measurement unit"}
	validates :std_quantity, :numericality => true, :presence => true
	validates :calories_per_quantity, :numericality => true, :presence => true
	validates :creator_id, :presence => true
	
	def create_ingredient
		save!  
		self
	end


	def self.list_pending_ingredients
	  Ingredient.where(approved: false)  
	end

	  
 	def approve_ingredient 
		update_attributes!(:approved => true)
	end
end
