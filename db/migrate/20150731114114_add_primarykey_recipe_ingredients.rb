class AddPrimarykeyRecipeIngredients < ActiveRecord::Migration
  def up
  	add_column :recipe_ingredients, :id, :primary_key
  end

  def down
  	execute "ALTER TABLE `recipe_ingredients` DROP PRIMARY KEY"
  	drop_column :recipe_ingredients, :id
  end
end
