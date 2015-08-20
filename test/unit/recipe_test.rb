require 'test_helper'

class RecipeTest < ActiveSupport::TestCase
  include ReusableFunctionsTests   
  
  test "create recipe" do
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert((recipe_copy.present?) && (recipe.id = recipe_copy.id), 'recipe not saved') 
    assert(recipe.ingredients.count ,'ingredients not inserted')
  
    assert(recipe.photos.count ,'images not inserted') #--TODO
    assert_equal(10800.0, recipe.total_calories, 'total calorie calculation wrong')
  end

  #needs to load data in recipe, ingredients, recipe_ingredients fixture
  test "update recipe" do
    params = {name: "xyz"}
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert((recipe_copy.present?) && (recipe.id = recipe_copy.id), 'recipe not saved') 
    user_copy = User.find_by_email('zomato@domain.com')
    recipe_copy.update_attributes(UPDATE_RECIPE_HASH)
    recipe_copy.update_recipe(photo_list: @@photo_list, ingredients_list: @@ingredients_list, current_user: user_copy)
    assert(recipe.ingredients.count,'ingredients not inserted')
    Rails.logger.debug recipe.photos.count
    assert(recipe.photos.count ,'images not inserted') #--TODO
    assert_equal(10800.0, recipe.total_calories, 'total calorie calculation wrong')
    recipe_check = Recipe.find(recipe_copy.id)
    assert(recipe_check.name == "xyz", 'recipe not updated')
  end

  test "rate recipe" do
    recipe = create_recipe_helper 
    recipe_copy = Recipe.find(recipe.id)
    assert(recipe_copy.present?, 'recipe not saved') 
    current_user = User.find_by_email('453ankitapalekar@gmail.com')
    rate_object = recipe_copy.rate_recipe( ratings: 4, current_user: current_user)
    assert(rate_object,'recipe not rated')
  end

  test "should not approve recipe" do 
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert_not_nil(recipe_copy, 'recipe not saved')
    current_user = User.find_by_email('zomato@domain.com')
    rec = recipe_copy.approve_recipe(current_user: current_user)
    assert_equal(rec.errors,"only admin can approve recipe")
  end

  test "should approve recipe" do 
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert_not_nil(recipe_copy, 'recipe not saved')
    user = User.find_by_email('453ankitapalekar@gmail.com')
    rec = recipe_copy.approve_recipe(current_user: user)
    assert(rec.approved,'recipe not approved')
    user = User.find_by_id(recipe.creator_id)
    assert_not_nil(user.present?, 'user is nil') 
    last_email = ActionMailer::Base.deliveries.last
    assert_not_nil(last_email, 'email buffer blank')
  end

  test "get recipe meal class" do
  	meal_class = Recipe.get_recipe_meal_class(ingredients_list: @@ingredients_list)
    assert_equal("non-veg", meal_class, 'meal class does not match')
	end

  test "reject recipe" do
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert_not_nil(recipe_copy, 'recipe not saved')
    current_user = User.find_by_email('453ankitapalekar@gmail.com')
    rec = recipe_copy.reject_recipe(current_user: current_user)
    assert(rec.rejected,'recipe not rejected')
    user = User.find_by_id(recipe.creator_id)
    assert_not_nil(user.present?, 'user is nil') 
    last_email = ActionMailer::Base.deliveries.last
    assert_not_nil(last_email, 'email buffer blank')
  end

  test "should not reject recipe" do
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert_not_nil(recipe_copy, 'recipe not saved')
    current_user = User.find_by_email('zomato@domain.com')
    rec = recipe_copy.reject_recipe(current_user: current_user)
    assert_equal(rec.errors,'only admin can reject recipe', 'message do not match')
  end

  test "list pending recipes" do
    recipe = create_recipe_helper
    recipe_copy = Recipe.find(recipe.id)
    assert_not_nil(recipe_copy, 'recipe not saved')
    current_user = User.find_by_email('zomato@domain.com')
    list = Recipe.list_recipes(list_type:'order_by_date', status: 'pending', current_user: current_user)
    list.each do |rec| 
      assert(!(rec.approved && rec.rejected), 'pending logic failed')
    end
  end


  test "list_my_top_rated_recipes" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com')
    list = Recipe.list_recipes(list_type:'order_by_aggregate_ratings', status: 'approved', current_user: current_user) 
    last_date = Time.zone.now
    last_count = 5
    list.each_with_index do |rec, index|
       assert(rec.approved, 'not approved recipe listed')
       assert((last_count >= rec.aggregate_ratings.to_i), 'wrong aggreagte listing')
       last_count = rec.aggregate_ratings.to_i
    end
  end

  
  test "list_my_most_rated_recipes" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com')
    list = Recipe.list_recipes(list_type:'order_by_most_rated', status: 'approved', current_user: current_user) 
    last_count = Rating.count.to_i
    list.each_with_index do |rec, index|
      assert(rec.approved, 'not approved recipe listed')
      assert((last_count >= rec.count.to_i), 'wrong aggreagte listing')
      last_count = rec.count.to_i
    end
  end


  test "list_my_pending recipes" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com')
    list = Recipe.list_recipes(list_type:'order_by_aggregate_ratings', status: 'approved', current_user: current_user) 
    list.each_with_index do |rec, index|
      assert(!rec.approved, 'approved error')
    end
  end
  

  test "list_my_approved_recipes" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com') 
    list = Recipe.list_recipes(list_type:'order_by_date', status: 'approved', current_user: current_user) 
      list.each_with_index do |rec, index|
      assert(rec.approved, 'not approved ')
    end
  end

  test "list_my_rejected_recipes" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com')
    list = Recipe.list_recipes(list_type:'order_by_date', status: 'rejected', current_user: current_user) 
    list.each_with_index do |rec, index|
      assert(rec.rejected, 'rejected error')
    end
  end

  test "list_top_rated_recipes" do
    make_join_table
    rate_randomly
    list = Recipe.list_recipes(list_type:'order_by_aggregate_ratings')
    last_rate = 5
    list.each_with_index do |rec, index|
      assert(rec.approved, 'approval error')
      # Rails::logger.debug rec.aggregate_ratings
      assert(last_rate >= rec.aggregate_ratings, 'wrong aggreagte listing')
      last_rate = rec.aggregate_ratings
    end
  end


  test "list_most_rated_recipes" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com')
    Rails::logger.debug current_user.inspect
    assert(current_user.present?, 'user not present')
    list = Recipe.list_recipes(list_type:'order_by_most_rated')
    last_count = Rating.count.to_i
    list.each_with_index do |rec, index|
      assert(rec.approved, 'approval error')
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

  test "list_rated_users" do
    make_join_table
    rate_randomly
    recipe_rating = Rating.all.shuffle.first
    assert(recipe_rating.persisted?, 'rating row does not exist')
    recipe = Recipe.find(recipe_rating.recipe_id)
    assert(recipe.persisted?,'recipe not existing')
    list_users = recipe.list_rated_users(ratings: recipe_rating.ratings)
    assert(list_users, 'list not found')
  end

  test "should not search user" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com') 
    query_hash = {:users => current_user}
    list = Recipe.search(:query_hash => query_hash)
    assert(list.empty?, 'wrong search')
  end


  test "should  search recipe" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com') 
    query_hash = {:recipe => 'gulab jamun'}
    list = Recipe.search(:query_hash => query_hash)
    assert(!list.empty?, 'wrong search')
  end

  test "should  search recipe containning ingredients" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com') 
    query_hash = {:ingredients => 'casew'}
    list = Recipe.search(:query_hash => query_hash)
    assert(!list.empty?, 'wrong search')
  end

  test "should search recipe in range of calories" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com') 
    query_hash = {:calories => ["10", "100"]}
    list = Recipe.search(:query_hash => query_hash)
    assert(!list.empty?, 'wrong search')
  end

  test "should search recipes wrt to given aggregate_ratings" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com') 
    query_hash = {:aggregate_ratings => 3}
    list = Recipe.search(:query_hash => query_hash)
    assert(!list.empty?, 'wrong search')
  end

  test "should search recipes wrt to meal_class" do
    make_join_table
    rate_randomly
    current_user = User.find_by_email('zomato@domain.com') 
    query_hash = {:meal_class => "veg"}
    list = Recipe.search(:query_hash => query_hash)
    assert(!list.empty?, 'wrong search')
  end



end
