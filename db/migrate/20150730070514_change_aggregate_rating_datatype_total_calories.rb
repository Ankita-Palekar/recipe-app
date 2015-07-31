class ChangeAggregateRatingDatatypeTotalCalories < ActiveRecord::Migration
  def up
  	change_column :recipes, :aggregate_ratings, :float
  	change_column :recipes, :total_calories, :float
  end

  def down
  	change_column :recipes, :aggregate_ratings, :integer
  	change_column :recipes, :total_calories, :integer
  end
end
