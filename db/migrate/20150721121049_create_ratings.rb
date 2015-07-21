class CreateRatings < ActiveRecord::Migration
  def up
    create_table :ratings do |t|
    	t.belongs_to :recipe, index:true
      t.belongs_to :user , index:true
      t.integer :rating
    end
    execute "ALTER TABLE ratings ADD CONSTRAINT fk_ratings_users FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE ratings ADD CONSTRAINT fk_recipes_recipes FOREIGN KEY (user_id) REFERENCES recipes(id)"
  end

  def end
  	execute "ALTER TABLE ratings DROP CONSTRAINT fk_ratings_users "
  	execute "ALTER TABLE ratings DROP CONSTRAINT fk_recipes_recipes"
  	drop_table :ratings
  end
end
