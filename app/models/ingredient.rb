require './static_data.rb'
class Ingredient < ActiveRecord::Base
	has_and_belongs_to_many :recipes
  attr_accessible :name, :meal_class, :std_measurement, :std_quantity, :calories_per_quantity

  validates :name, :presence => true
  validates :meal_class, :inclusion => {:in => StaticData::MEAL_CLASS, :message => "meal_class can only contain jain, veg, non-veg"}
  validates :std_measurement, :inclusion => {:in => StaticData::STD_QUANTITY, :message => "invalid measurement unit"}
	validates :std_quantity, :numericality => true
	validates :calories_per_quantity, :numericality => true

  # REVIEW: Naming. Why is this function name plural? What are the arguments
  # of this function? What is the return value of this function?
	def create_ingredients
		#code to save ingredients to db
	end

 	def accept_ingredient(ingredient_id:)
		#set approved flag to true  
	end
end