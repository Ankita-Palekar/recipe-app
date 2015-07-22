class AddIndexRecipesIngredientRatings < ActiveRecord::Migration
  def up
  	add_index :recipes, :user_id
  	add_index :ingredients, :user_id
  	add_index :ratings, :user_id
  	add_index :ratings, :recipe_id
  end

  def down
  	remove_index :recipes, :user_id
  	remove_index :ingredients, :user_id
  	remove_index :ratings, :user_id
  	remove_index :ratings, :recipe_id
  end
end
