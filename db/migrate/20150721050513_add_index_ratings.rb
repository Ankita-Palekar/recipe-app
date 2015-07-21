class AddIndexRatings < ActiveRecord::Migration
  def change
  	add_index :ratings, [:user_id, :recipe_id], :unique => true
  end
end
