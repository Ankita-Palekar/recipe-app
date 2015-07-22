class IngredientRecipe < ActiveRecord::Migration
  def up
  	create_table :ingredients_recipes do |t|
  		t.belongs_to :recipe, index:true
  		t.belongs_to :ingredient, index:true
  		t.integer :quantity
  	end
  	add_index :ingredients_recipes, [:recipe_id, :ingredient_id], :unique => true

  	execute "ALTER TABLE ingredients_recipes ADD CONSTRAINT fk_ingredients_recipes_recipe FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE ON UPDATE CASCADE"
  	execute "ALTER TABLE ingredients_recipes ADD CONSTRAINT fk_ingredients_recipes_ingredient FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE ON UPDATE CASCADE"
 	end 
  
  def down
  	execute "ALTER TABLE ingredients_recipes DROP CONSTRAINT fk_ingredients_recipes_recipe"
  	execute "ALTER TABLE ingredients_recipes DROP CONSTRAINT fk_ingredients_recipes_ingredient"
  	drop_table :ingredients_recipes
  end

end
