class CreateRecipes < ActiveRecord::Migration
  def up
    create_table :recipes do |t|
    	t.belongs_to :user, index:true
    	t.string :name, :null => false
    	t.text :image_links
    	t.text :description, :null => false
    	t.string :meal_class, :null => false
    	t.integer :total_calories
    	t.integer :aggregate_ratings
    	t.integer :serves
    	t.boolean :approved, :dafault => false
      t.timestamps
    end
    execute "ALTER TABLE recipes ADD CONSTRAINT fk_recipes_users FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def down
  	execute "ALTER TABLE recipes DROP CONSTRAINT fk_recipes_users"
  	drop_table :recipes
  end
end
