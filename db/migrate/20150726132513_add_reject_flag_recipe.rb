class AddRejectFlagRecipe < ActiveRecord::Migration
  def up
  	add_column :recipes, :rejected, :boolean, default:false
  end

  def down
  	remove_column :recipes, :rejected
  end
end
