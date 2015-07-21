class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
    	t.string :email, :null => false
    	t.string :password_digest, :null => false
    	t.boolean :is_admin , :default => false
      t.timestamps
    end
    add_index :users, :email, :unique => true
    
  end
  def down
  	
  end
end
