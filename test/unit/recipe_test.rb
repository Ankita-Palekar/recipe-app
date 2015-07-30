require 'test_helper'

class RecipeTest < ActiveSupport::TestCase
  include ReusableFunctionsTests   
  test "create recipe" do
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert(recipe_copy.present?, 'recipe not saved') 
    assert(recipe.ingredients.count > 0,'ingredients not inserted')
    assert(recipe.photos.count ,'images not inserted') #--TODO
    assert_equal(15600, recipe.total_calories, 'total calorie calculation wrong')
  end

  #needs to load data in recipe, ingredients, recipe_ingredients fixture

  test "rate recipe" do
    recipe = create_recipe_helper 
    recipe_copy = Recipe.find(recipe.id)
    assert(recipe_copy.present?, 'recipe not saved') 
    recipe_copy.rate_recipe(rater_id: 3, ratings: 4)
    assert(recipe_copy.ratings,'recipe not rated')
  end

  test "approve recipe" do 
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert_not_nil(recipe_copy, 'recipe not saved')
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
    list.each do |rec| 
      assert(!(rec.approved && rec.rejected), 'pending logic failed')
    end
  end


  test "list order_by_date home page recipes" do
    # make_join_table
    # rate_randomly
    list = Recipe.list_home_page_recipes(list_type: 'order_by_date', page_nav: 1, limit: 5)
    last_date = Time.zone.now
    list.each_with_index do |rec, index|
      assert(rec.approved, 'not approved recipe listed')
      Rails.logger.debug last_date
      Rails.logger.debug rec.created_at
      assert(last_date >= rec.created_at, 'wrong date listing')
      last_date = rec.created_at
    end
  end

  test "list order_by_aggregate_ratings home page recipes" do
    make_join_table
    rate_randomly
    list = Recipe.list_home_page_recipes(list_type: 'order_by_aggregate_ratings', page_nav: 1, limit: 5)
    last_rate = 5
    list.each_with_index do |rec, index|
      assert(rec.approved, 'not approved recipe listed')
      assert(last_rate >= rec.aggregate_ratings, 'wrong aggreagte listing')
      last_rate = rec.aggregate_ratings
    end
  end

  test "list order_by_most_rated home page recipes" do
    make_join_table
    rate_randomly
    list = Recipe.list_home_page_recipes(list_type: 'order_by_most_rated', page_nav: 1, limit: 5)
    last_count = Rating.count.to_i
    list.each_with_index do |rec, index|
      assert(rec.approved, 'not approved recipe listed')
      assert((last_count >= rec.count.to_i), 'wrong aggreagte listing')
      last_count = rec.count.to_i
    end
  end


  test "list my pending recipes order_by_date" do
    make_join_table
    rate_randomly
    list = Recipe.list_my_recipes(status: 'my_pending_recipes',creator_id: 1, list_type: 'order_by_date', page_nav: 1, limit: 5)
    list.each_with_index do |rec, index|
      assert(!rec.approved, 'approved error')
    end
  end


  test "list my approved recipes order_by_date" do
    make_join_table
    rate_randomly
    list = Recipe.list_my_recipes(status: 'my_approved_recipes',creator_id: 1, list_type: 'order_by_date', page_nav: 1, limit: 5)
    last_date = Time.zone.now
    list.each_with_index do |rec, index|
      assert(rec.approved, 'not approved ')
      assert(last_date >= rec.created_at, 'wrong date listing')
      last_date = rec.created_at
    end
  end

  test "list my rejected recipes order_by_date" do
    make_join_table
    rate_randomly
    list = Recipe.list_my_recipes(status: 'my_rejected_recipes',creator_id: 1, list_type: 'order_by_date', page_nav: 1, limit: 5)
    last_date = Time.zone.now
    list.each_with_index do |rec, index|
      assert(rec.rejected, 'rejected error')
        assert(last_date >= rec.created_at, 'wrong date listing')
      last_date = rec.created_at
    end
  end

  test "list my approved recipes order_by_aggregate_ratings" do
    make_join_table
    rate_randomly
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
    make_join_table
    rate_randomly
    list = Recipe.list_my_recipes(status: 'my_approved_recipes',creator_id: 1, list_type: 'order_by_most_rated', page_nav: 1, limit: 5)
    last_count = Rating.count.to_i
    list.each_with_index do |rec, index|
      assert(rec.approved, 'approval error')
      # Rails::logger.debug rec.aggregate_ratings
      assert(last_count >= rec.count.to_i, 'wrong count')
      last_count = rec.count.to_i
    end
  end

  test "get recipe aggregate ratings" do
    recipe = Recipe.find(1)
    recipe.get_recipe_aggregate_ratings
    assert_equal(recipe.aggregate_ratings, 4, 'aggregate calculation failing')
  end


  test "get ratings count hash" do
    recipe = Recipe.find(1)
    match_hash = {5=>1, 4=>2}
    hash =  recipe.ratings.group(:ratings).count 
    assert_equal(hash, match_hash, 'hash does not match')
  end
end
