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
  
  # REVIEW -- what is the return value of this function?
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

          # REVIEW -- read Hash#except as provided by active_support. Use it.
          ingredient = Ingredient.new(ingre)

          # REVIEW -- why is the create_ingredient function returning an ID
          # whereas create_recipe doesn't? why the inconsistency?
          ingredient_id =  ingredient.create_ingredient           
          recipe_ingredient = RecipeIngredient.new(recipe_id: recipe_id, ingredient_id: ingredient.id, quantity: quantity)
          recipe_ingredient.save!
        end

        # REVIEW -- understand the difference between bang and non-bang
        # operators in ActiveRecord. Use the right one here.
        update_attributes(:total_calories => total_calories)
      end
    rescue Exception => message
      # REVIEW -- why are you catching all errors here? Let them bubble up if
      # you don't have any way to intelligently handle them.
      puts message
      puts errors.inspect
    end
  end

  #call Recipe.show_pending_recipes
  #output :list of pending recipes

  # REVIEW -- function name. You are not "showing" the recipes anywhere. This
  # is a pure API method call. It knows nothing about the UI.
  def self.show_pending_recipes
    Recipe.where(approved: false)  
  end
  
  # output message : ingredient approved
  def approve_recipe
    begin
      update_attributes!(:approved => true)
      #ingredient_ids is the method added by has_many

      # REVIEW -- you can directly get access to all ingerdient object by
      # `self.ingredients`
      ingredient_ids.each do |id| 
        # REVIEW -- N+1 SQL bug. Read about it.
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
    # REVIEW -- why are meal classes re-defined here?
    meal_class = ["non-veg", "veg", "jain"]
    least_meal_class = meal_class[meal_class.length-1]

    # REVIEW -- use reduce.
    ingredients_list.each do |ingre|
      least_meal_class = ingre[:meal_class] if meal_class.index(least_meal_class) >meal_class.index(ingre[:meal_class])
    end
    least_meal_class
  end
end
