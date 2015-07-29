module ReusableFunctionsTests
	extend ActiveSupport::Concern
	included do 


		def create_user_helper
			user_hash =  { :name => 'zomato', :email => 'zomato@domain.com', :password => 'zomato123', :password_confirmation  => 'zomato123'}
			User.create(user_hash)
		end

		def create_recipe_helper
			ingredients_list = [{:ingredient_id => 49 , :name => "casew", :quantity => 10, :meal_class =>  "jain", :calories_per_quantity => 500 , :std_measurement => "gm", :std_quantity => 1, :creator_id => 2},{:name=>"sugar", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => 2}, {:name=>"casew", :meal_class=>"non-veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => 2}]
			user = create_user_helper
		  recipe = Recipe.new(:name => "papaya casew" ,:description => "crush papaya", :serves => 2, :aggregate_ratings => 0, :creator_id => user.id)  
		  recipe.create_recipe(ingredients_list: ingredients_list)    
		  recipe
		end
	end
end	