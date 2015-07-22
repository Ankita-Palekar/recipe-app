class CreateIngredients < ActiveRecord::Migration
  def up
    create_table :ingredients do |t|
    	t.belongs_to :user , index:true
    	t.string :name , :null => false
    	t.string :meal_class, :null => false 
    	t.string :std_measurement
    	t.integer :std_quantity
    	t.integer :calories_per_quantity

      t.timestamps
    end
    execute "ALTER TABLE ingredients ADD CONSTRAINT fk_ingredients_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE"
  end
  def down
  	execute "ALTER TABLE ingredients DROP CONSTRAINT  fk_ingredients_users"
  	drop_table :ingredients
  end
end
