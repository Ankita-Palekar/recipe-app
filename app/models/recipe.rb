require 'static_data.rb'
class Recipe < ActiveRecord::Base
	belongs_to :user
	# has_and_belongs_to_many :ingredients
  has_many :recipe_ingredients
  has_many :ingredients, :through => :recipe_ingredients

	has_many :ratings, :dependent => :destroy
	#habtm should destroy row entries in the join table automatically it will not destroy from single ingredients or recipe table 
	
  attr_accessible :name, :image_links, :description, :meal_class, :total_calories, :aggregate_ratings, :serves, :approved, :user_id

  validates :name, :presence => true
  validates :description, :presence => true
  validates :meal_class, :presence => true
  validates :serves, :numericality => true
  validates :aggregate_ratings, :numericality => true
  validates :user_id, :presence => true
  
  def create_recipe(ingredients_list:)
    begin
      Recipe.transaction do 
        save! 
        recipe_id = id
        total_calories = 0
        ingredients_list.each do |ingre|
          quantity = ingre[:quantity]
          ingre.delete(:quantity)
          total_calories += quantity * ingre[:calories_per_quantity]
          ingredient = Ingredient.new(ingre)
          ingredient_id =  ingredient.create_ingredient           
          recipe_ingredient = RecipeIngredient.new(recipe_id: recipe_id, ingredient_id: ingredient.id, quantity: quantity)
          recipe_ingredient.save!
        end
        update_attributes(:total_calories => total_calories)
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
  
  # output message : ingredient approved
  def approve_recipe
    begin
      update_attributes!(:approved => true)
      #ingredient_ids is the method added by has_many
      ingredient_ids.each do |id| 
        ingredient = Ingredient.find_by_id(id)
        ingredient.approve_ingredient
      end
      user = User.find_by_id(user_id)
      user.send_email_notification_recipe_approved
    rescue Exception => message
      puts errors.message
    end
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
