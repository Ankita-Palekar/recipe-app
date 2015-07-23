class AddDefaultApprovedRecipesIngredients < ActiveRecord::Migration
  def up
  	change_column :recipes, :approved, :boolean, default: false
  	change_column :ingredients, :approved, :boolean, default: false
  end

  def down
  	change_column :recipes, :approved, :default => nil
  	change_column :ingredients, :approved, :default => nil
  end
end
