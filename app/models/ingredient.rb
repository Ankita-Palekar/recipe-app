class Ingredient < ActiveRecord::Base
	has_and_belongs_to_many :recipes
  attr_accessible :name, :meal_class, :std_measurement, :stq_quantity, :calories_per_quantity
end
