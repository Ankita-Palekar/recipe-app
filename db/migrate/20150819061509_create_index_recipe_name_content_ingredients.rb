class CreateIndexRecipeNameContentIngredients < ActiveRecord::Migration
  def up
  	execute "CREATE INDEX recipe_name on recipes using gin(to_tsvector('english', name))"
  	execute "CREATE INDEX recipe_description on recipes using gin(to_tsvector('english', description))"
  	execute "CREATE INDEX ingredient_name on ingredients using gin(to_tsvector('english', name))"
  end

  def down
  	execute "DROP INDEX recipe_name"
  	execute "DROP INDEX recipe_description"
  	execute "DROP INDEX ingredient_name"
  end
end
