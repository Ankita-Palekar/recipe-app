require 'test_helper'

class RecipeTest < ActiveSupport::TestCase

  ingredients_list = [{:ingredient_id => 49 , :name => "casew", :quantity => 10, :meal_class =>  "veg", :calories_per_quantity => 500 , :std_measurement => "gm", :std_quantity => 1, :creator_id => 2},{:name=>"sugar", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => 2}, {:name=>"casew", :meal_class=>"veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => 2}]

  
  recipe_create_block = Proc.new do 
    recipe = Recipe.new(:name => "papaya casew" ,:description => "crush papaya", :serves => 2, :aggregate_ratings => 0, :creator_id => 1)  
    recipe.create_recipe(ingredients_list: ingredients_list)
    recipe
  end


  test "create recipe" do
    # recipe.create_recipe(ingredients_list: ingredients_list)
    recipe = recipe_create_block.call
    recipe_copy = Recipe.find(recipe.id)
    assert(recipe_copy.present?, 'recipe not saved')
    
    total_cal = ingredients_list.reduce(0) do |memo,ingre|
      memo +=  ingre[:quantity] / ingre[:std_quantity] * ingre[:calories_per_quantity] 
    end
    ingredient_id_list = Ingredient.pluck(:id)
    rec_ingredient_id_list =  recipe.recipe_ingredients.pluck(:ingredient_id)

    assert_equal(ingredient_id_list.sort, rec_ingredient_id_list.sort, 'ingredient id recipe id pair not inlcuded')
    assert_equal(total_cal, recipe.total_calories, 'total calorie calculation wrong')
  end

  #needs to load data in recipe, ingredients, recipe_ingredients fixture

  test "approve recipe" do
    recipe = Recipe.last
    assert_not_nil(recipe, 'recipe is nil')
    # Rails::logger.debug recipe.inspect
    recipe.approve_recipe
    assert(recipe.approved,'recipe not approved')
  end

  test "get recipe meal class" do
    recipe = recipe_create_block.call
  	meal_class_list = Ingredient::MEAL_CLASS
  	meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)
    assert_equal(meal_class,recipe.meal_class, 'meal class does not match')
	end
end
