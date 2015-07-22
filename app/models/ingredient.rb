class Ingredient < ActiveRecord::Base
	has_and_belongs_to_many :recipes
  attr_accessible :name, :meal_class, :std_measurement, :std_quantity, :calories_per_quantity

  validates :name, :presence => true
  # REVIEW -- define possible options as a constant in this class, eg.
  # MEAL_CLASSES = ['jain', 'veg', 'non-veg'] and use that everywhere it's
  # required
  validates :meal_class, :inclusion => {:in => ["jain", "veg", "non-veg"], :message => "meal_class can only contain jain, veg, non-veg"}
  validates :std_measurement, :inclusion => {:in => ["teaspoon", "tablespoon", "fluid ounce", "gill", "cup", "pint", "quart", "gallon", "ml", "l", "dl", "pounds", "ounce", "mg", "g", "kg", "mm", "cm", "m", "inch"], :message => "invalid measurement unit"}
	validates :std_quantity, :numericality => true
	validates :calories_per_quantity, :numericality => true


  # REVIEW
	def create_ingredients
		#code to save ingredients to db
	end

	def ingredient_accept
	  
	end

end
