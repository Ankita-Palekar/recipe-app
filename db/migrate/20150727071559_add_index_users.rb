class AddIndexUsers < ActiveRecord::Migration
  def change
  	add_index :recipes, :creator_id, index:true
  	add_index :ingredients, :creator_id, index:true
  	add_index :ratings, :rater_id, index:true
  end
end
