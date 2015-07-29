require 'test_helper'

class RecipeTest < ActiveSupport::TestCase
  include ReusableFunctionsTests
  @@ingredients_list = [{:ingredient_id => 49 , :name => "casew", :quantity => 10, :meal_class =>  "jain", :calories_per_quantity => 500 , :std_measurement => "gm", :std_quantity => 1, :creator_id => 2},{:name=>"sugar", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => 2}, {:name=>"casew", :meal_class=>"non-veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => 2}]

   
  test "create recipe" do
    recipe = Recipe.new(:name => "papaya casew" ,:description => "crush papaya", :serves => 2, :aggregate_ratings => 0, :creator_id => 1)  
    recipe.create_recipe(ingredients_list: @@ingredients_list)
    # recipe = recipe_create_block.call
    recipe_copy = Recipe.find(recipe.id)
    assert(recipe_copy.present?, 'recipe not saved') 
    assert(recipe.ingredients,'ingredients not inserted')
    assert_equal(15600, recipe.total_calories, 'total calorie calculation wrong')
  end

  #needs to load data in recipe, ingredients, recipe_ingredients fixture

  test "approve recipe" do
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert_not_nil(recipe_copy, 'recipe not saved')
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

  test "reject recipe" do
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert_not_nil(recipe_copy, 'recipe not saved')
    recipe_copy.reject_recipe
    assert(recipe_copy.rejected, 'recipe reject failed')
  end

  test "list pending recipes" do
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert_not_nil(recipe_copy, 'recipe not saved')
    list = Recipe.list_pending_recipes(page_nav: 1, limit: 2)
    found_recipe = nil 
    list.each do |rec|
      if rec.id == recipe_copy.id 
        found_recipe = rec
        Rails::logger.debug found_recipe.inspect
        break
      end
    end
    assert((found_recipe.approved && found_recipe.rejected), 'pending logic failed')
  end


  test "list order_by_date home page recipes" do
    list = Recipe.list_home_page_recipes(list_type: 'order_by_date', page_nav: 1, limit: 5)
    last_date = Time.zone.now
    list.each_with_index do |rec, index|
      assert(rec.approved, 'not approved recipe listed')
      # assert(last_date < rec.created_at, 'wrong date listing')
      last_date = rec.created_at
    end
  end

  test "list order_by_aggregate_ratings home page recipes" do
    list = Recipe.list_home_page_recipes(list_type: 'order_by_aggregate_ratings', page_nav: 1, limit: 5)
    last_rate = 5
    list.each_with_index do |rec, index|
      assert(rec.approved, 'not approved recipe listed')
      assert(last_rate >= rec.aggregate_ratings, 'wrong aggreagte listing')
      last_rate = rec.aggregate_ratings
    end
  end

  test "list order_by_most_rated home page recipes" do
    list = Recipe.list_home_page_recipes(list_type: 'order_by_most_rated', page_nav: 1, limit: 5)
    last_count = 100
    list.each_with_index do |rec, index|
      assert(rec.approved, 'not approved recipe listed')
      assert(last_count >= rec.count, 'wrong aggreagte listing')
      last_count = rec.count
    end
  end


  test "list my pending recipes order_by_date" do
    list = Recipe.list_my_recipes(status: 'my_pending_recipes',creator_id: 1, list_type: 'order_by_date', page_nav: 1, limit: 5)
    list.each_with_index do |rec, index|
      assert(!rec.approved, 'approved error')
    end
  end


  test "list my approved recipes order_by_date" do
    list = Recipe.list_my_recipes(status: 'my_approved_recipes',creator_id: 1, list_type: 'order_by_date', page_nav: 1, limit: 5)
    list.each_with_index do |rec, index|
      assert(rec.approved, 'not approved ')
    end
  end

  test "list my rejected recipes order_by_date" do
    list = Recipe.list_my_recipes(status: 'my_rejected_recipes',creator_id: 1, list_type: 'order_by_date', page_nav: 1, limit: 5)
    list.each_with_index do |rec, index|
      assert(rec.rejected, 'rejected error')
    end
  end

  test "list my approved recipes order_by_aggregate_ratings" do
    list = Recipe.list_my_recipes(status: 'my_approved_recipes',creator_id: 1, list_type: 'order_by_aggregate_ratings', page_nav: 1, limit: 5)
    last_rate = 5
    list.each_with_index do |rec, index|
      assert(rec.approved, 'approval error')
      # Rails::logger.debug rec.aggregate_ratings
      assert(last_rate >= rec.aggregate_ratings, 'wrong aggreagte listing')
      last_rate = rec.aggregate_ratings
    end
  end


  test "list my approved recipes order_by_most_rated" do
    list = Recipe.list_my_recipes(status: 'my_approved_recipes',creator_id: 1, list_type: 'order_by_most_rated', page_nav: 1, limit: 5)
    last_count = 100
    list.each_with_index do |rec, index|
      assert(rec.approved, 'approval error')
      # Rails::logger.debug rec.aggregate_ratings
      assert(last_count >= rec.count, 'wrong count')
      last_count = rec.count
    end
  end


end
