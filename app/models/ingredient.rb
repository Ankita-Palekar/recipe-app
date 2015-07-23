class Ingredient < ActiveRecord::Base
	# has_and_belongs_to_many :recipes
	has_many :recipe_ingredients
	has_many :recipes, :through => :recipe_ingredients #change naming otherwise @@SCREWED


  attr_accessible :name, :meal_class, :std_measurement, :std_quantity, :calories_per_quantity, :approved
	MEAL_CLASS = %w(jain veg non-veg)
	STD_QUANTITY = ["teaspoon", "tablespoon", "fluid ounce", "gill", "cup", "pint", "quart", "gallon", "ml", "l", "dl", "pounds", "ounce", "mg", "g", "kg", "mm", "cm", "m", "inch"]
	
  validates :name, :presence => true
  validates :meal_class, :inclusion => {:in => MEAL_CLASS, :message => "meal_class can only contain jain, veg, non-veg"}
  validates :std_measurement, :inclusion => {:in => STD_QUANTITY, :message => "invalid measurement unit"}
	validates :std_quantity, :numericality => true, :presence => true
	validates :calories_per_quantity, :numericality => true, :presence => true

	# def update_attributes(hash)
 #    hash.keys.each do |key|
 #      m = "#{key}="
 #      self.send(m, hash[key]) if self.respond_to?(m)
 #    end
	# end

	# output :message => got saved sucessfully

	def create_ingredient
		begin
			Ingredient.transaction do
				save!  
			end
		rescue Exception => message
			puts message.inspect
			puts errors.inspect
		end
		puts id.inspect
		id
	end

	  
 	def approve_ingredient
 		begin
		 	update_attributes!(:approved => true)
 		rescue Exception => e
 			# REVIEW -- whe are you catching all exceptions here?
 			puts e
 			puts errors.messages
 		end

	end
end
