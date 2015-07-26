class Recipe < ActiveRecord::Base
  belongs_to :user
  # has_and_belongs_to_many :ingredients
  has_many :recipe_ingredients
  has_many :ingredients, :through => :recipe_ingredients
  has_many :ratings, :dependent => :destroy
  
  attr_accessible :name, :image_links, :description, :meal_class, :total_calories, :aggregate_ratings, :serves, :approved, :creator_id, :rejected

  validates :name, :presence => true
  validates :description, :presence => true
  validates :meal_class, :presence => true
  validates :serves, :numericality => true
  validates :aggregate_ratings, :numericality => true
  validates :creator_id, :presence => true
  
  find_user_and_send_mail = lambda do |creator_id, function_name|
    user = User.find_by_id(creator_id)
    user.send_email_notification_for_recipes(creator_id, function_name)
  end

  def create_recipe(ingredients_list:)
    Recipe.transaction do 
      self.meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)
      save! 
      total_calories = 0
      ingredients_list.each do |ingre|
        total_calories += ingre[:quantity] / ingre[:std_quantity] * ingre[:calories_per_quantity] #calculating total calories in recipe
          if ingre.has_key?(:ingredient_id)
            ingredient_id = ingre[:ingredient_id] 
          else
            ingredient = Ingredient.new(ingre.except(:quantity))
            ingredient.create_ingredient
            ingredient_id  = ingredient.id
          end
        recipe_ingredient = RecipeIngredient.new(recipe_id: id, ingredient_id: ingredient_id, quantity: ingre[:quantity])
        recipe_ingredient.save!
      end
      update_attributes!(:total_calories => total_calories)
    end
    self
  end

 
  def self.list_pending_recipes(page_nav:, limit:)
    Recipe.where(approved: false).order('created_at desc').limit(limit).offset((page_nav-1)*limit)  
  end

  
  def approve_recipe 
    update_attributes!(:approved => true)
    self.ingredients.each do |ingredient| 
      ingredient.approve_ingredient
    end
    self.find_user_and_send_mail.call(creator_id, 'recipe_approval_email')
  end

  def reject_recipe
    update_attributes!(:rejected => true)
    self.find_user_and_send_mail.call(creator_id, 'recipe_rejected_email')
    # user = User.find_by_id(creator_id)
    # user.send_email_notification_recipe_rejected
  end


  def self.get_recipe_meal_class(ingredients_list:)
    meal_class = Ingredient::MEAL_CLASS
    memo = meal_class[meal_class.length-1]
    least_meal_class = ingredients_list.reduce(memo) do |memo, ingre|
      meal_class.index(memo) > meal_class.index(ingre[:meal_class]) ? ingre[:meal_class] : memo
    end
  end

  #user recipes related functions

  def self.list_latest_created_recipes(page_nav:, limit:)
    Recipe.includes(:ingredients).where(:approved => true).order('created_at desc').limit(limit).offset((page_nav-1)*limit).each do |rec|
      rec_ingredients_quantity  = rec.recipe_ingredients
      new_ingredients_list =  rec.ingredients.map.with_index do |ingredient, index|
        ingredient[:quantity] =  rec_ingredients_quantity[index][:quantity]
        ingredient
      end
      rec[:ingredients_list] = new_ingredients_list
      rec 
    end    
  end
end
