class AddIngredientRecipeIndex < ActiveRecord::Migration
  def change
  	add_index :ingredients_recipes, [:recipe_id, :ingredient_id], :unique => true
  end
end
