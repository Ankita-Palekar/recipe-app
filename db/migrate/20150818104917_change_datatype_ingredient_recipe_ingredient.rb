class ChangeDatatypeIngredientRecipeIngredient < ActiveRecord::Migration
  def up
  	# remove_column :ingredients, :std_quantity
   #  add_column :ingredients, :std_quantity, :float, default: 0.0
  	
  	# remove_column :ingredients, :calories_per_quantity
   #  add_column :ingredients, :calories_per_quantity, :float, default: 0.0
    
   #  remove_column :recipe_ingredients, :quantity
   #  add_column :recipe_ingredients, :quantity, :float, default: 0.0
  	change_column :ingredients, :std_quantity, :decimal
  	change_column :ingredients, :calories_per_quantity, :decimal
  	change_column :recipe_ingredients, :quantity, :decimal
  end

  def down
  	change_column :ingredients, :std_quantity, :integer
  	change_column :ingredients, :calories_per_quantity, :integer
  	change_column :recipe_ingredients, :quantity, :integer
  end
end
