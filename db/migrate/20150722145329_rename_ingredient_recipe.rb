class RenameIngredientRecipe < ActiveRecord::Migration
  def up
  	rename_table :ingredients_recipes, :recipe_ingredients
  end

  def down
  	rename_table :recipe_ingredients, :ingredients_recipes 
  end
end
