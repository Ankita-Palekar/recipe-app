class Ingredient < ActiveRecord::Base
	# has_and_belongs_to_many :recipes
	belongs_to :user, :foreign_key => 'creator_id'
	has_many :recipe_ingredients
	has_many :recipes, :through => :recipe_ingredients 

  attr_accessible :name, :meal_class, :std_measurement, :std_quantity, :calories_per_quantity, :approved, :creator_id
	MEAL_CLASS = %w(non-veg veg jain)
	STD_QUANTITY = ["teaspoon", "tablespoon", "fluid ounce", "gill", "cup", "pint", "quart", "gallon", "ml", "l", "dl", "pounds", "ounce", "mg", "g", "kg", "mm", "cm", "m", "inch"]
	
  validates :name, :presence => true
  validates :meal_class, :inclusion => {:in => MEAL_CLASS, :message => "meal_class can only contain jain, veg, non-veg"}
  validates :std_measurement, :inclusion => {:in => STD_QUANTITY, :message => "invalid measurement unit"}
	validates :std_quantity, :numericality => true, :presence => true
	validates :calories_per_quantity, :numericality => true, :presence => true
	validates :creator_id, :presence => true
	validates :name, :uniqueness => true
 	
 	before_validation :strip_whitespace, :only => [:name]

	scope :approved_ingredients, -> {where(:approved => true)}
	# scope :my_unapproved_ingredients, ->(creator_id) {where(:approved => false, creator_id: creator_id )}
	scope :unapproved_ingredients, -> {where(:approved => false)}
	
	def create_ingredient
		save!
		self
	end


	def update_ingredient(params:)
		update_attributes(params) 
		self
	end

	def self.list_pending_ingredients
	  Ingredient.where(approved: false)  
	end

 	def approve_ingredient 
		update_attributes(:approved => true)
	end

	def self.getIngredients(current_user)
		# Ingredient.approved_ingredients.my_unapproved_ingredients(current_user.id)
		current_user.ingredients.unapproved_ingredients + Ingredient.approved_ingredients
	end

	private 
	def strip_whitespace
	  self.name = self.name.strip
	end
end
