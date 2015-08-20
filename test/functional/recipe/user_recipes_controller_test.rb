require 'test_helper'

class Recipe::UserRecipesControllerTest < ActionController::TestCase
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
    put :update, :id => 1, recipe: {:name => "xxx", :description => "sugar and some more things",:serves => 4, :aggregate_ratings => 0, :creator_id => @current_user_id}, ingredient:[{:name=>"masala", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => @current_user_id}, {:name=>"casew1", :meal_class=>"veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => @current_user_id}], existing_ingredient:[{:ingredient_id => 49, :std_measurement =>2, :std_quantity => 20, :calories_per_quantity => 20, :meal_class => "veg"}], :avatar =>[]
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
end
