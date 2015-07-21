class AddColumnCategory < ActiveRecord::Migration
  def change 
  	add_column :recipes, :category_id ,:integer ,references: :categories
  end
end
