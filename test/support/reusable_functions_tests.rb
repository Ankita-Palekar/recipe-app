module ReusableFunctionsTests
	extend ActiveSupport::Concern
	included do 
		@@ingredients_list = [{:ingredient_id => 49 , :name => "casew", :quantity => 10, :meal_class =>  "jain", :calories_per_quantity => 500 , :std_measurement => "gm", :std_quantity => 1, :creator_id => 2},{:name=>"sugar", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => 2}, {:name=>"tomato", :meal_class=>"non-veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => 2}]
		
		@@photo_list =  [Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/test-image.jpg'), 'image/jpeg')]
		
		USER_HASH ={:name => 'zomato', :email => 'zomato@domain.com', :password => 'zomato123', :password_confirmation  => 'zomato123'}
		RECIPE_HASH = {:name => "Pudin hara juice" ,:description => "mint leaves", :serves => 2, :aggregate_ratings => 0, :creator_id=>2}
		def create_user_helper
			User.create(USER_HASH)
		end

		def make_join_table
			Recipe.find(:all, :limit=>5).each do |rec|
				ingred =  Ingredient.find(:all).shuffle[0..5].first
				rec_ing = rec.recipe_ingredients.new(quantity: rand(10..100))
				rec_ing.ingredient = ingred
				rec_ing.save
			end
			# Rails::logger.debug RecipeIngredient.all.inspect
		end


		def rate_randomly
			user_list = User.pluck(:id)
			recipes = Recipe.find(:all, :limit => 5) 
			recipes.each do |rec|
				Rails::logger.debug user_list
	 			rec.approve_recipe
				rater_id = user_list.shuffle.first
				ratings = rand(0..5)	
				recipe_id = rec.id
				rec.rate_recipe(rater_id: rater_id, ratings: ratings) if (Rating.where(recipe_id: recipe_id, rater_id: rater_id)).empty?
			end
		end

		def create_recipe_helper
			user = create_user_helper
			Rails::logger.debug @@photo_list.inspect
		  recipe = Recipe.new(RECIPE_HASH)  
		  recipe.create_recipe(ingredients_list: @@ingredients_list, photo_list: @@photo_list)    
		  recipe
		end

	end
end	