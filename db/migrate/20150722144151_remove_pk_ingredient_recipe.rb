class RemovePkIngredientRecipe < ActiveRecord::Migration
  def up
  	remove_column :ingredients_recipes, :id
  end

  def down
  	add_column :ingredients_recipes, :id, index:true
  end
end
