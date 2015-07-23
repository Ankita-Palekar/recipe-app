require 'test_helper'

class RecipeTest < ActiveSupport::TestCase
  test "recipe create" do
    recipe = Recipe.new(:recipe1)
    assert !recipe.save
  end
end
