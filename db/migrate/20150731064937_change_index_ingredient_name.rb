class ChangeIndexIngredientName < ActiveRecord::Migration
  def up
  	add_index :ingredients, :name, :unique => true
  end

  def down
  	remove_index :ingredients, :name
  end
end
