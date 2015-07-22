require 'static_data.rb'
class Recipe < ActiveRecord::Base
	belongs_to :user
	# has_and_belongs_to_many :ingredients
  has_many :recipe_ingredients
  has_many :ingredients, :through => :recipe_ingredients

	has_many :ratings, :dependent => :destroy
	#habtm should destroy row entries in the join table automatically it will not destroy from single ingredients or recipe table 
	
  attr_accessible :name, :image_links, :description, :meal_class, :total_calories, :aggregate_ratings, :serves, :approved

  # validates :name, :presence => true
  # validates :description, :presence => true
  # validates :meal_class, :presence => true
  # validates :serves, :numericality => true
  # validates :aggregate_ratings, :numericality => true
  # validates :user_id, :presence => true

  def create_recipe(ingredients_list:)
    begin
    	Recipe.transaction do 
        ingredients_list.each do |ingre|
          ingredient = Ingredient.new
          ingredient.update_attributes(ingre)
          # ingredient.create_ingredient(:ingredient_params => ingre)
          ingredient.create_ingredient
        end
        meal_class = Recipe.get_recipe_meal_class(:ingredients_list => ingredients_list)
        update_attributes!(:meal_class => meal_class)
        save! 
        puts "====="
        puts id.inspect
    	end
    rescue Exception => message
      puts message
      puts errors.inspect
    end
  end


 

  #call Recipe.show_pending_recipes
  #output :list of pending recipes
  def self.show_pending_recipes
    Recipe.where(approved: false)  
  end

  def self.calculate_total_recipe_calories
    #get data from the qunatity in the table
  end

  
  # output message : ingredient approved
  def approve_recipe
    # @approved = true
    # save
    # user = User.find_by_id(recipe.user_id)
    # user.send_email_notification_recipe_accepted
  end

  # output :meal_class
  def self.get_recipe_meal_class(ingredients_list:)
    meal_class = ["non-veg", "veg", "jain"]
    least_meal_class = meal_class[meal_class.length-1]
    ingredients_list.each do |ingre|
      least_meal_class = ingre[:meal_class] if meal_class.index(least_meal_class) >meal_class.index(ingre[:meal_class])
    end
    least_meal_class
  end

end
