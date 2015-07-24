require 'test_helper'

class RecipeTest < ActiveSupport::TestCase

  ingredients_list = [{:name=>"soya", :meal_class=>"veg", :std_measurement=>"l", :std_quantity=>1, :calories_per_quantity=>250, :quantity => 2, :creator_id => 1}, {:name=>"casew", :meal_class=>"veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => 1}]

  test "create recipe" do
    recipe = Recipe.new(:name => "papaya casew" ,:description => "crush papaya", :serves => 2, :aggregate_ratings => 0, :creator_id => 1)  
    recipe.create_recipe(ingredients_list: ingredients_list)
    recipe_last = Recipe.last
    assert(recipe_last.valid?,'invalid recipe')
    assert_equal(recipe, recipe_last, 'both are not equal')
  end

  test "approve recipe" do
    recipe = Recipe.last
    assert_not_nil(recipe, 'recipe is nil')
    Rails::logger.debug recipe.inspect
    recipe.approve_recipe
    assert(recipe.approved,'recipe not approved')
  end

  test "get recipe meal class" do
  	meal_class_list = ["non-veg", "veg", "jain"]
  	meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)
  	Rails::logger.debug meal_class
  	assert(meal_class_list.include?(meal_class),'meal class not included in meal class list')
	end
end
