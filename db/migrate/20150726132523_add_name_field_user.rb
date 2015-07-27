class AddNameFieldUser < ActiveRecord::Migration
  def up
  	add_column :users, :name, :string
  end

  def down
  	drop_column :users, :name
  end
end
