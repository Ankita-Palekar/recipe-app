class Recipe < ActiveRecord::Base
  belongs_to :user
  has_many :photos
  # has_and_belongs_to_many :ingredients
  has_many :recipe_ingredients
  has_many :ingredients, :through => :recipe_ingredients
  has_many :ratings, :dependent => :destroy
  
  attr_accessible :name, :image_links, :description, :meal_class, :total_calories, :aggregate_ratings, :serves, :approved, :creator_id, :rejected, :avatar

  # has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  # validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  validates :name, :presence => true
  validates :description, :presence => true
  validates :meal_class, :presence => true
  validates :serves, :numericality => true
  validates :aggregate_ratings, :numericality => true
  validates :creator_id, :presence => true



  scope :free_text, ->(query) {where("name like ?", "%#{query}%")}
  scope :aggregate_ratings, ->(ratings) {where(aggregate_ratings: ratings)}
  scope :calories, -> (calories) {where("total_calories = ? * serves", "#{calories.to_i}")}
  scope :ingredients, ->(query) {joins(:ingredients).where("ingredients.name like ?", "%#{query}%")}


  
  @@find_user_and_send_mail = lambda do |creator_id, function_name|
    user = User.find_by_id(creator_id)
    user.send_email_notification_for_recipes(:function_name => function_name)
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
    Recipe.where(approved: false, rejected: false).order('created_at desc').limit(limit).offset((page_nav-1)*limit)  
  end

  
  def approve_recipe
    Recipe.transaction do
      update_attributes!(:approved => true, :rejected=>false)
      self.ingredients.each do |ingredient| 
        puts ingredient.inspect
        ingredient.approve_ingredient
      end
      @@find_user_and_send_mail.call(creator_id, 'recipe_approval_email')
    end 
  end

  def reject_recipe
    update_attributes!(:rejected => true)
    @@find_user_and_send_mail.call(creator_id, 'recipe_rejected_email')
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
    Recipe.where(:approved => true).order('created_at desc').limit(limit).offset((page_nav-1)*limit) 
  end

  def self.list_top_rated_recipes_wrt_aggregate(page_nav: , limit:)
    Recipe.order("aggregate_ratings desc").limit(limit).offset((page_nav-1)*limit)
  end

  def self.list_top_rated_recipes_wrt_count(page_nav: , limit:)
    Recipe.select("recipes.*, count(ratings.recipe_id) as count").joins(:ratings).group("recipes.id").order("count desc").limit(limit).offset((page_nav-1)*limit)
  end

  def rate_recipe(rater_id:, ratings:)
    Recipe.transaction do
      (approved == true) & (rater_id != creator_id) ? Rating.create!(rater_id: rater_id, recipe_id: id, ratings: ratings) : false
      update_attributes!(:aggregate_ratings => get_recipe_aggregate_ratings)
    end
  end

  def get_recipe_aggregate_ratings
    ratings_hash = ratings.group(:ratings).count #recipe.ratings.group(:ratings).count
    (ratings_hash.reduce(0) do |memo, pair|
      memo += pair[0] * pair[1]
    end) / (ratings_hash.values.reduce(:+))
  end

  def get_recipe_details
    return {recipe_content: Recipe.includes(:ratings, :photos, :ingredients).where(:id => id).first,
      ratings_histogram: get_ratings_count_hash
    }
  end

  def get_ratings_count_hash
    ratings.group(:ratings).count 
  end


  #user specific functions
  
  def self.list_my_recipes(page_nav:, limit:, creator_id:)
    Recipe.where(:creator_id => creator_id, :approved=> true).order('created_at desc').limit(limit).offset((page_nav-1)*limit)
  end

  def self.list_most_popular_recipes_wrt_aggregate(creator_id:, page_nav:, limit:)
    Recipe.where(:id => creator_id).order("aggregate_ratings desc").limit(limit).offset((page_nav-1)*limit)
  end

  def self.list_most_popular_recipes_wrt_count(creator_id:, page_nav:, limit:)
    Recipe.select("recipes.*, count(ratings.recipe_id) as count").joins(:ratings).where(:creator_id => creator_id).group("recipes.id").order("count desc").limit(limit).offset((page_nav-1)*limit)
  end

  def self.list_my_pending_recipes(creator_id:, page_nav:, limit:)
    Recipe.where(approved: false, rejected: false ,creator_id: creator_id).order('created_at desc').limit(limit).offset((page_nav-1)*limit)  
  end

  def self.list_my_rejected_recipes(creator_id:, page_nav:, limit:)
    Recipe.where(rejected: true ,creator_id: creator_id).order('created_at desc').limit(limit).offset((page_nav-1)*limit)  
  end

  def list_rated_users(ratings:)
    Rating.joins('inner join users on users.id = ratings.rater_id').select("users.name as name, users.email as email").where(:recipe_id=>id, :ratings => ratings)
  end
 

 def self.search(flag:, query:)
   searched_recipes = Recipe.scoped
   # searched_recipes = searched_recipes.free_text(query) if flag == 'free_text'
   # searched_recipes = searched_recipes.aggregate_ratings(query) if flag == 'aggregate_ratings'
   # searched_recipes = searched_recipes.calories(query) if flag == 'calories'
   # searched_recipes = searched_recipes.ingredients(query) if flag == 'ingredients'
   searched_recipes = searched_recipes.send flag, query
   searched_recipes
 end
end
