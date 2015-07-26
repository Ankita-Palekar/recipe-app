class ChangeUsertoRaterinRatingRatings < ActiveRecord::Migration
  def up
  	rename_column :ratings, :user_id, :rater_id
  	rename_column :ratings, :rating, :ratings
  	add_index :ratings, [:rater_id, :recipe_id], :unique => true
  end

  def down
  	rename_column :ratings, :rater_id, :user_id
  	rename_column :ratings, :ratings, :rating
  	remove_index :ratings, [:rater_id, :recipe_id]
  end
end
