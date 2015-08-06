require 'test_helper'

class User::UserRecipesControllerTest < ActionController::TestCase
  include SessionsHelper
  include ReusableFunctionsTests
  
  setup do
    @recipe = recipes(:one)
    @user = users(:two)
    @owner = users(:one)
  end

  test "should not show my_pending_recipes" do
    get :my_pending_recipes
    assert_response 302
  end

  test "should show my_pending_recipes" do
    sign_in @user
    get :my_pending_recipes
    assert_response :success
    assert_template('/common/recipe_list')
  end



  test "should not show my_top_rated_recipes" do
    get :my_top_rated_recipes
    assert_response 302
  end

  test "should show my_top_rated_recipes" do
    sign_in @user
    get :my_top_rated_recipes
    assert_response :success
    assert_template('/common/recipe_list')
  end


  test "should not show my_most_rated_recipes" do
    get :my_most_rated_recipes
    assert_response 302
  end

  test "should show my_most_rated_recipes" do
    sign_in @user
    get :my_most_rated_recipes
    assert_response :success
    assert_template('/common/recipe_list')
  end


  test "should not show my_approved_recipes" do
    get :my_approved_recipes
    assert_response 302
  end

  test "should show my_approved_recipes" do
    sign_in @user
    get :my_approved_recipes
    assert_response :success
    assert_template('/common/recipe_list')
  end
  


  test "should not show my_rejected_recipes" do
    get :my_rejected_recipes
    assert_response 302
  end

  test "should not get index" do
    get :index
    assert_response 302
    # assert_template('recipe_list')
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_template('/common/recipe_list')
  end

  test "should not get edit to any user" do
    sign_in @user
    get :edit, id: @recipe
    assert_response 302
  end

  test "should get edit to owner" do
    sign_in @owner
    get :edit, id: @recipe
    assert_response :success
  end

  test "should not create recipe with empty ingredients empty photos" do
    sign_in @user 
    post :create, recipe: {:name => "Methayee", :description => "sugar syrup",:serves => 4, :aggregate_ratings => 0, :creator_id => @current_user_id}
    assert_template('/common/create_recipe')
    assert_equal('Recipe Images and Ingredients cannnot be blank', flash[:notice])
  end

  test "should not create recipe if not signed in " do

    post :create, recipe: {:name => "Methayee", :description => "sugar syrup",:serves => 4, :aggregate_ratings => 0, :creator_id => @current_user_id}
    assert_response 302
  end
 
  test "should create recipe" do
    sign_in @user
    assert_difference('Recipe.count') do
    post :create, recipe: {:name => "Methayee", :description => "sugar syrup",:serves => 4, :aggregate_ratings => 0, :creator_id => @current_user_id}, ingredient:[{:name=>"masala", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => @current_user_id}, {:name=>"casew1", :meal_class=>"veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => @current_user_id}], existing_ingredient:[{:ingredient_id => 49, :std_measurement =>2, :std_quantity => 20, :calories_per_quantity => 20, :meal_class => "veg"}], :avatar => @@photo_list
    end
    assert_redirected_to recipe_path(assigns(:recipe))
    assert_equal('Recipe created successfully', flash[:notice], message="not equal")
  end

  test "should update recipe if owner" do
    sign_in @owner
    put :update, :id => 1, recipe: {:name => "xxx", :description => "sugar and some more things",:serves => 4, :aggregate_ratings => 0, :creator_id => @current_user_id}, ingredient:[{:name=>"masala", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => @current_user_id}, {:name=>"casew1", :meal_class=>"veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => @current_user_id}], existing_ingredient:[{:ingredient_id => 49, :std_measurement =>2, :std_quantity => 20, :calories_per_quantity => 20, :meal_class => "veg"}], :avatar => @@photo_list 
    assert_response :success
  end

  test "should rate_recipe" do
    sign_in @user
    post :rate_recipe, recipe:{:id => @recipe.id, :ratings => 5}
    assert_equal('successfully rated', flash[:notice][:message]) 
  end

  test "should not recipe if not logged in" do
    post :rate_recipe, recipe:{:id => @recipe.id, :ratings => 3}
    assert_response 302
  end

  # test "should get new" do
  #   test_before_test_login_user
  #   get :new
  #   Rails::logger.debug @response.inspect
  #   assert_response :success
  # end

  
  # test "should approve_recipe" do
  #   test_before_test_login_user
  #   assert_generates '/recipes/approve_recipe', controller: "recipes", action: "approve_recipe"
  #   put :approve_recipe, recipe:{:id => @recipe.id , :approved => "true"}
  #   assert_equal('successfully approved', flash[:notice][:message], message="not equal") 
  # end


  # test "should reject_recipe" do
  #   test_before_test_login_user
  #   assert_generates '/recipes/reject_recipe', controller: "recipes", action: "reject_recipe"
  #   put :reject_recipe, recipe:{:id => @recipe.id, :rejected => "true"}
  #   assert_equal('successfully rejected', flash[:notice][:message]) 
  # end

  # test "should rate_recipe" do
  #   test_before_test_login_user
  #   assert_generates '/recipes/rate', controller: "recipes", action: "rate_recipe"
  #   post :rate_recipe, recipe:{:id => @recipe.id, :ratings => 3}
  #   assert_equal('successfully rated', flash[:notice][:message]) 
  # end


  # test "should update recipe" do
  #   test_before_test_login_user
  #   assert_difference('Recipe.count') do
  #     put :update, :id => 1, recipe: {:name => "xxx", :description => "sugar syrup",:serves => 4, :aggregate_ratings => 0, :creator_id => @current_user_id}, ingredient:[{:name=>"masala", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => @current_user_id}, {:name=>"casew1", :meal_class=>"veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => @current_user_id}], existing_ingredient:[{:ingredient_id => 49, :std_measurement =>2, :std_quantity => 20, :calories_per_quantity => 20, :meal_class => "veg"}], :avatar => @@photo_list
  #   end
  #   # Rails::logger.debug @recipe
  #   assert_redirected_to recipe_path(assigns(@recipe))
  #   assert_equal('Recipe was successfully edited', flash[:notice], message="not equal")
  # end

  # test "should get_search" do
  #   test_before_test_login_user
  #   assert_generates "/search", { controller: "recipes", action: "search"}
  #   assert_response(:success)
  # end

  # test "should search recipes free_text" do
  #   test_before_test_login_user
  #   assert_generates "/search", { controller: "recipes", action: "searchrecipes"}
  #   put :search, flag:'free_text' , query: 'gulab jamun'  #aggregate_ratings, ingredients, calories,   
  #   assert_template('search')
  # end

  # test "should search recipes aggregate_ratings" do
  #   test_before_test_login_user
  #   assert_generates "/search", { controller: "recipes", action: "searchrecipes"}
  #   put :search, recipe: {flag:'aggregate_ratings' , query: 3 } 
  #   assert_template('search')
  # end

  # test "should search recipes ingredients" do
  #   test_before_test_login_user
  #   assert_generates "/search", { controller: "recipes", action: "searchrecipes"}
  #   put :search, recipe: {flag:'ingredients' , query: 3 }  
  #   assert_template('search')
  # end

  # test "should search recipes calories" do
  #   test_before_test_login_user
  #   assert_generates "/search", { controller: "recipes", action: "searchrecipes"}     
  #   put :search, recipe: {flag:'calories' , query: 100 } 
  #   assert_template('search')
  # end

  # test "should search recipes meal_class" do
  #   test_before_test_login_user
  #   assert_generates "/search", { controller: "recipes", action: "searchrecipes"}     
  #   put :search, recipe: {flag:'meal_class' , query: 'veg' } 
  #   assert_template('search')
  # end


  # test "should show rated users list" do
  #   test_before_test_login_user
  #   assert_generates "/recipes/1/3/rated_users", { controller: "recipes", action: "rated_users_list", id: "1" , ratings: 3}
  #   get :rated_users_list, :id => 1, :ratings =>  3
  #   Rails::logger.debug @response.inspect
  #   assert_response :success
  #   assert_not_nil assigns(:users_list)
  # end


  # test "should show top rated recipes" do
  #   # test_before_test_login_user
  #   assert_generates "/recipes/top_rated_recipes", { controller: "recipes", action: "top_rated_recipes"}
  #   get :top_rated_recipes 
  #   assert_response :success
  #   assert_template('/common/recipe_list')
  # end

  # test "should show most rated recipes" do
  #   # test_before_test_login_user
  #   assert_generates "/recipes/most_rated_recipes", { controller: "recipes", action: "most_rated_recipes"}
  #   get :top_rated_recipes 
  #   assert_response :success
  #   assert_template('/common/recipe_list')
  # end



  # test "should update recipe" do
  #   put :update, id: @recipe, recipe: {  }
  #   assert_redirected_to recipe_path(assigns(:recipe))
  # end

  # test "should destroy recipe" do
  #   assert_difference('Recipe.count', -1) do
  #     delete :destroy, id: @recipe
  #   end

  #   assert_redirected_to recipes_path
  # end
end
