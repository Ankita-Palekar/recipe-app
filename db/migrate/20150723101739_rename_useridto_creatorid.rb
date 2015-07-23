class RenameUseridtoCreatorid < ActiveRecord::Migration
  def up
  	rename_column :recipes, :user_id, :creator_id
  	rename_column :ingredients, :user_id, :creator_id
  end

  def down
  	rename_column :recipes, :creator_id, :user_id
  	rename_column :recipes, :creator_id, :user_id
  end
end
