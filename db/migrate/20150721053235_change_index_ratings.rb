class ChangeIndexRatings < ActiveRecord::Migration
  def up
  	change_column :ratings, :user_id, :integer, references: :users, index: true
  	change_column :ratings, :recipe_id, :integer, references: :recipes, index: true
  end

  def down
  	#method to change the refrence
  end
end
