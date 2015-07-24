require 'test_helper'

class IngredientTest < ActiveSupport::TestCase

  test "create ingredient" do
    ingredient = Ingredient.new(:name=>"pepper", :meal_class=>"jain",:std_measurement=>"kg", :std_quantity=>2, :calories_per_quantity=>20, :creator_id=>3)
 		ingredient.create_ingredient
		ingred_copy = Ingredient.last
  	Rails::logger.debug ingred_copy.inspect
  	assert_not_nil(ingred_copy, 'ingredient is nil')
  	assert_equal(ingred_copy.id,ingredient.id,'ingredient not created')
  end
  

  # needs to load fixture
  test "approve ingredient" do
		ingredient = Ingredient.last
		assert_not_nil(ingredient, 'ingredient is nil')
		ingredient.approve_ingredient
		assert(ingredient.approved, 'ingredient not approved') 
	end


end
