require 'test_helper'

class Recipe::AdminRecipesControllerTest < ActionController::TestCase
  include SessionsHelper
  include ReusableFunctionsTests
  setup do
    @recipe = recipes(:one)
    @admin = users(:one)
    @user = users(:two)
  end

  test "should test is admin" do
    assert(@admin.is_admin, 'user is admin')
  end

  test "should not show admin_pending recipes if not logged in" do
    get :admin_pending_recipes
    assert_response 302
  end

  test "should not show admin_pending recipes if not owner" do
    sign_in @user
    get :admin_pending_recipes
    assert_response 302
  end

  test "should show admin_pending recipes if admin" do
    sign_in @admin
    test_should_test_is_admin
    get :admin_pending_recipes
    assert_template('/common/recipe_list')
  end

  test "should approve_recipe" do
    sign_in @admin
    test_should_test_is_admin
    put :approve_recipe, recipe:{:id => @recipe.id , :approved => "true"}
    assert_equal('successfully approved', flash[:notice][:message], message="not equal") 
  end

  test "should not approve_recipe if not signed in" do
    put :approve_recipe, recipe:{:id => @recipe.id , :approved => "true"}
    assert_response 302
  end

  test "should not approve_recipe if not admin" do
    sign_in @user
    put :approve_recipe, recipe:{:id => @recipe.id , :approved => "true"}
    assert_response 302
  end


  test "should reject_recipe" do
    sign_in @admin
    put :reject_recipe, recipe:{:id => @recipe.id, :rejected => "true"}
    assert_equal('successfully rejected', flash[:notice][:message]) 

  end

  test "should not reject_recipe if not signed in" do
    put :reject_recipe, recipe:{:id => @recipe.id, :rejected => "true"}
    assert_response 302
  end

  test "should not reject_recipe if not admin" do
    sign_in @user
    put :reject_recipe, recipe:{:id => @recipe.id, :rejected => "true"}
    assert_response 302
  end
end
