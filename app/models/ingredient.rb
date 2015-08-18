class Ingredient < ActiveRecord::Base
	# has_and_belongs_to_many :recipes
	belongs_to :creator, :foreign_key => 'creator_id', :class_name => User
	has_many :recipe_ingredients
	has_many :recipes, :through => :recipe_ingredients 

  attr_accessible :name, :meal_class, :std_measurement, :std_quantity, :calories_per_quantity, :approved, :creator_id
	MEAL_CLASS = %w(non-veg veg jain)
	STD_QUANTITY = ["dz", "teaspoon", "tablespoon", "fluid ounce", "gill", "cup", "pint", "quart", "gallon", "ml", "l", "dl", "pounds", "ounce", "mg", "g", "kg", "mm", "cm", "m", "inch"]
	
	STD_QUANTITY_NAMES = ["dozen", "teaspoon", "tablespoon", "ounce", "gill", "cup", "pint", "quart", "gallon", "milli liter", "liter",  "deci liter", "pounds", "ounce", "mili grams", "grams", "kilo grams", "mili meter", "centi,meter", "meter","inch"]

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
	
	def normalise_ingredient_name
		self.name = self.name.gsub(/[^\w\s]/, "")
		name
	end

	def create_ingredient
		self.normalise_ingredient_name
		if !Ingredient.exists?(:name => self.name)
			save
			self
		else
			ing = Ingredient.where(:name => self.name).first
		end
	end


	def update_ingredient(params:)
		self.normalise_ingredient_name
		update_attributes(params) 
		self
	end

	def self.list_pending_ingredients
	  Ingredient.where(approved: false)  
	end

 	def approve_ingredient 
		update_attributes(:approved => true)
	end

	# REVIEW: snake_case
	def self.getIngredients(current_user)
		# Ingredient.approved_ingredients.my_unapproved_ingredients(current_user.id)
		current_user.ingredients.unapproved_ingredients + Ingredient.approved_ingredients
	end

	private 
	def strip_whitespace
	  self.name = self.name.strip
	end
end
