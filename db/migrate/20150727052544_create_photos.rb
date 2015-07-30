class CreatePhotos < ActiveRecord::Migration
  def up
    create_table :photos do |t|
    	t.attachment :avatar
    	t.belongs_to :recipe, index:true 
      t.timestamps
    end
    add_index :photos , :recipe_id
    execute "ALTER TABLE photos ADD CONSTRAINT fk_photos_recipes FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE"
  end
  def down
  	execute "ALTER TABLE photos DROP CONSTRAINT fk_photos_recipes"
  	drop_table :photos
  end
end
