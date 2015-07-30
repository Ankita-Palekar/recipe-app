class AddAvatarColumnsToUsers < ActiveRecord::Migration
  def up
 		 # add_attachment :users, :avatar
  end
  def down
  	# remove_column :users, :avatar_file_name
  	# remove_column :users, :avatar_content_type
  	# remove_column :users, :avatar_file_size
  	# remove_column :users, :avatar_updated_at  
  end
end
