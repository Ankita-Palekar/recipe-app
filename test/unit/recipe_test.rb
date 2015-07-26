require 'test_helper'

class RecipeTest < ActiveSupport::TestCase

  ingredients_list = [{:ingredient_id => 49 , :name => "casew", :quantity => 10, :meal_class =>  "jain", :calories_per_quantity => 500 , :std_measurement => "gm", :std_quantity => 1, :creator_id => 2},{:name=>"sugar", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => 2}, {:name=>"casew", :meal_class=>"non-veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => 2}]

  
    

  test "create recipe" do
    recipe = Recipe.new(:name => "papaya casew" ,:description => "crush papaya", :serves => 2, :aggregate_ratings => 0, :creator_id => 1)  
    recipe.create_recipe(ingredients_list: ingredients_list)
    # recipe = recipe_create_block.call
    recipe_copy = Recipe.find(recipe.id)
    assert(recipe_copy.present?, 'recipe not saved') 
    assert(recipe.ingredients,'ingredients not inserted')
    assert_equal(15600, recipe.total_calories, 'total calorie calculation wrong')
  end

  #needs to load data in recipe, ingredients, recipe_ingredients fixture

  test "approve recipe" do
    recipe = Recipe.last
    assert_not_nil(recipe, 'recipe is nil')
    # Rails::logger.debug recipe.inspect
    recipe.approve_recipe
    assert(recipe.approved,'recipe not approved')
    user = User.find_by_id(recipe.creator_id)
    assert_not_nil(user, 'user is nil') 
    user.send_email_notification_recipe_approved
    last_email = ActionMailer::Base.deliveries.last
    assert_equal(user.email, last_email.to.first)
  end

  test "get recipe meal class" do
  	meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)
    assert_equal("non-veg", meal_class, 'meal class does not match')
	end
end
