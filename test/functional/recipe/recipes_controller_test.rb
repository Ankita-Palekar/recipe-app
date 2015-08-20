require 'test_helper'

class Recipe::RecipesControllerTest < ActionController::TestCase
  include SessionsHelper
  include ReusableFunctionsTests
  
  setup do
    @recipe = recipes(:one)
  end

  test "should show top rated recipes" do
    get :top_rated_recipes 
    assert_response :success
    assert_template('/common/recipe_list')
  end

  test "should most rated recipes" do
    get :most_rated_recipes 
    assert_response :success
    assert_template('/common/recipe_list')
  end

  test "should show search page" do
    get :search
    assert_response :success
    assert_template('/common/recipe_list')
  end

  test "should show searchd_recipes page" do
    post :search_recipes, flag:{:ingredients => 'sugar', :calories => ["10", "100"], :meal_class => 'veg', :aggregate_ratings => 3 , :recipe => "gulab jamun"}
    assert_response :success
    assert_template('/common/recipe_list')
  end

  test "should show recipe" do
    get :show, id: @recipe
    assert_response :success
  end
end
