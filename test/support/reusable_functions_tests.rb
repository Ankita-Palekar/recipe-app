module ReusableFunctionsTests
	extend ActiveSupport::Concern
	included do 
		@@ingredients_list = [{:ingredient_id => 49 , :name => "casew", :quantity => 10, :meal_class =>  "jain", :calories_per_quantity => 500 , :std_measurement => "gm", :std_quantity => 1, :creator_id => 2},{:name=>"sugar", :meal_class=>"veg", :std_measurement=>"kg", :std_quantity=>1, :calories_per_quantity=>5050, :quantity => 2, :creator_id => 2}, {:name=>"casew", :meal_class=>"non-veg", :std_measurement=>"mg", :std_quantity=>10, :calories_per_quantity=>50, :quantity => 100, :creator_id => 2}]
		
		# @@photo_list = File.new("test/fixtures/test-image.jpg")

		# @@photo_list = File.new(File.join(Rails.root, "test/fixtures", "test-image.jpg"), 'rb')
		@@photo_list =  [Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/test-image.jpg'), 'image/jpeg')]
		USER_HASH ={:name => 'zomato', :email => 'zomato@domain.com', :password => 'zomato123', :password_confirmation  => 'zomato123'}
		RECIPE_HASH = {:name => "Pudin hara juice" ,:description => "mint leaves", :serves => 2, :aggregate_ratings => 0}

		# USERS_LIST = []
		# RECIPE_ID_LIST= []
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
			recipe_list = Recipe.pluck(:id)
			recipes = Recipe.find(:all, :limit => 5) 

			recipes.each do |rec|
				Rails::logger.debug user_list.shuffle.first
				Rails::logger.debug rand(0..5)
	 			rec.approve_recipe
				rec.rate_recipe(rater_id: user_list.shuffle.first, ratings: rand(0..5))
			end
		end

		def create_recipe_helper
			user = create_user_helper
			Rails::logger.debug @@photo_list.inspect
		  recipe = Recipe.new(:name => "Pudin hara juice" ,:description => "mint leaves", :serves => 2, :aggregate_ratings => 0, :creator_id => user.id)  
		  recipe.create_recipe(ingredients_list: @@ingredients_list, photo_list: @@photo_list)    
		  recipe
		end

		# def create_recipe_list_helper
		# 	(0..10).each do 
		# 		RECIPE_HASH[:creator_id] = USERS_LIST.sample
		# 		RECIPE_HASH[:name] = (0...8).map { (65 + rand(26)).chr }.join
		# 		recipe = create_recipe_helper
		# 		RECIPE_LIST[].push(recipe.id)
		# 	end
		# end

		# def create_user_list_helper
		# 	(0..10).each do 
		# 		USER_HASH[:email]  = rand.to_s[2..10] + '@' +'domain.com'
		# 		user = create_user_helper
		# 		USERS_LIST.push(user.id)	
		# 	end
		# end
	end
end	