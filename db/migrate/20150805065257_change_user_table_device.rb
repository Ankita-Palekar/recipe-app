class ChangeUserTableDevice < ActiveRecord::Migration
  def change
  	change_table :users do |t|
	  	t.database_authenticatable
			t.confirmable
	  	t.recoverable
	  	t.rememberable
	  	t.trackable
	  	t.token_authenticatable
  	end
  end
end
