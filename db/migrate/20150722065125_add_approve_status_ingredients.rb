class AddApproveStatusIngredients < ActiveRecord::Migration
  def up
  	add_column :ingredients ,:approved, :boolean, :default => false
  end

  def down
  	remove_column :ingredients, :approved
  end
end
