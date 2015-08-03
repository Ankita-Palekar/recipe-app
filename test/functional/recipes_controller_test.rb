require 'test_helper'

class RecipesControllerTest < ActionController::TestCase
include SessionsHelper
include 
include ReusableFunctionsTests
  setup do
    @recipe = recipes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:recipes)
  end

  test "should get new" do
    session[:user_id] = 1
    get :new
    Rails::logger.debug @response.inspect
    assert_response :success
  end

  test "should create recipe" do
    session[:user_id] = 1
    current_user_id = @current_user.id if logged_in?
    assert_difference('Recipe.count') do
    post :create, recipe: {:name => "Methayee", :description => "sugar syrup",:serves => 4, :aggregate_ratings => 0, :creator_id => current_user_id}, ingredient:[{:name=>"masala", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => current_user_id}, {:name=>"casew1", :meal_class=>"veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => current_user_id}], existing_ingredient:[{:ingredient_id => 49, :std_measurement =>2, :std_quantity => 20, :calories_per_quantity => 20, :meal_class => "veg"}], :avatar => @@photo_list
    end
    assert_redirected_to recipe_path(assigns(:recipe))
    assert_equal('Recipe created successfully', flash[:notice], message="not equal")
  end

  test "should create recipe empty ingredients empty photos" do
    session[:user_id] = 1
    current_user_id = @current_user.id if logged_in?
    assert_difference('Recipe.count') do
      post :create, recipe: {:name => "Methayee", :description => "sugar syrup",:serves => 4, :aggregate_ratings => 0, :creator_id => current_user_id}
    end
    assert_redirected_to new_recipe_path
    assert_equal('', flash[:notice], message="not equal")
  end

  test "should approve_recipe" do
    session[:user_id] = 1
    @current_user = current_user if logged_in?
    put :approve_recipe, recipe:{:id => @recipe.id , :approved => "true"}
    assert(@recipe.approved, 'recipe not approved')
    assert_equal('successfully approved', flash[:notice], message="not equal") 
  end


  test "should reject_recipe" do
    session[:user_id] = 1
    @current_user = current_user if logged_in?
    put :reject_recipe, recipe:{:id => @recipe.id, :rejected => "true"}
          
    assert(@recipe.rejected, 'recipe not rejected')
    assert_equal('successfully rejected', flash[:notice], message="not equal") 
  end

  test "should rate_recipe" do
    session[:user_id] = 1
    @current_user = current_user if logged_in?
    put :rate_recipe, recipe:{:id => @recipe.id, :ratings => 3}
    Rails::logger.debug @rate.inspect
    assert_equal('successfully rated',@rate.notice, message="not equal") 
  end


  test "should show recipe" do
    session[:user_id] = 1
    get :show, id: @recipe
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @recipe
    assert_response :success
  end

  test "should update recipe" do
    session[:user_id] = 1
    current_user_id = @current_user.id if logged_in?
    assert_difference('Recipe.count') do
    
    put :update, recipe: {:name => "Methayee", :description => "sugar syrup",:serves => 4, :aggregate_ratings => 0, :creator_id => current_user_id}, ingredient:[{:name=>"masala", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => current_user_id}, {:name=>"casew1", :meal_class=>"veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => current_user_id}], existing_ingredient:[{:ingredient_id => 49, :std_measurement =>2, :std_quantity => 20, :calories_per_quantity => 20, :meal_class => "veg"}], :avatar => @@photo_list
    end
    Rails::logger.debug @recipe
    # assert_redirected_to recipe_path(assigns(:ingredient))
    assert_redirected_to recipe_path(assigns(:recipe))
    assert_equal('Recipe was successfully edited', flash[:notice], message="not equal")
  end

  test "should search recipes free_text" do
    session[:user_id] = 1
    current_user_id = @current_user.id if logged_in?
    put :search, flag:'free_text' , query: 'gulab jamun'  #aggregate_ratings, ingredients, calories,   
    Rails::logger.debug @recipe_list.inspect
    assert_template('search')
  end

  test "should search recipes aggregate_ratings" do
    session[:user_id] = 1
    current_user_id = @current_user.id if logged_in?
    put :search, recipe: {flag:'aggregate_ratings' , query: 3 } 
    assert_template('search')
  end

  test "should search recipes ingredients" do
    session[:user_id] = 1
    current_user_id = @current_user.id if logged_in?
    put :search, recipe: {flag:'ingredients' , query: 3 }  
    assert_template('search')
  end

  test "should search recipes calories" do
    session[:user_id] = 1
    current_user_id = @current_user.id if logged_in?
    put :search, recipe: {flag:'aggregate_ratings' , query: 3 } 
    assert_template('search')
  end

  test "should show rated users list" do
    get :rated_users_list 
    assert_response :success
    assert_not_nil assigns(:users_list)
  end

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
