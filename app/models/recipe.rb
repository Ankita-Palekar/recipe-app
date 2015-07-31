class Recipe < ActiveRecord::Base
  include SessionsHelper

  belongs_to :user
  has_many :photos, :dependent => :destroy
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

  scope :free_text, ->(query) {where("name ILIKE ?", "%#{query}%")}
  scope :aggregate_ratings, ->(ratings) {where(aggregate_ratings: ratings)}
  scope :meal_class, ->(meal_class) {where(meal_class: meal_class)}
  scope :calories, -> (calories) {where("total_calories = ? * serves", "#{calories.to_i}")}
  scope :ingredients, ->(query) {joins(:ingredients).where("ingredients.name ILIKE ?", "%#{query}%")}
  scope :approved, -> {where(:approved => true)}
  scope :order_by_date, -> {order('created_at desc')} 
  scope :order_by_aggregate_ratings, -> {order('aggregate_ratings desc')} 
  scope :my_approved_recipes, ->(creator_id) {where(:creator_id => creator_id, :approved=> true)}
  scope :my_rejected_recipes, ->(creator_id) {where(:creator_id => creator_id, :rejected=> true)}
  scope :my_pending_recipes, ->(creator_id) {where(approved: false, rejected: false ,creator_id: creator_id)}
  scope :ordered_by_count, -> {order("count desc")}
  scope :order_by_most_rated, -> {select("recipes.*, count(ratings.recipe_id) as count").joins(:ratings).group("recipes.id").ordered_by_count}
  scope :page_navigation, ->(limit, page_nav) {limit(limit).offset((page_nav-1)*limit) }
  scope :ratings_count_hash, -> {ratings.group(:ratings).count }
  scope :pending, -> {where(approved: false, rejected: false)}
  scope :photos, -> {joins(:photos)}
  scope :include_photos, -> {includes(:photos)}
  @@find_user_and_send_mail = lambda do |creator_id, function_name|
    user = User.find_by_id(creator_id)
    user.send_email_notification_for_recipes(:function_name => function_name)
  end

  def create_recipe(ingredients_list:, photo_list:)
    Recipe.transaction do 
      self.meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)
      save! 
      total_calories = 0
      ingredients_list.each do |ingre|
        total_calories += ingre[:quantity].to_i / ingre[:std_quantity].to_i * ingre[:calories_per_quantity].to_i #calculating total calories in recipe
          if ingre.has_key?(:ingredient_id)
            # ingredient_id = ingre[:ingredient_id] 
            ingredient = Ingredient.find(ingre[:ingredient_id])
          else
            ingredient = Ingredient.new(ingre.except(:quantity))
            ingredient.creator_id = creator_id
            ingredient.create_ingredient
            # ingredient_id  = ingredient.id
          end
        # recipe_ingredient = RecipeIngredient.new(recipe_id: id, ingredient_id: ingredient_id, quantity: ingre[:quantity])
        recipe_ingredient = self.recipe_ingredients.new(quantity: ingre[:quantity])
        recipe_ingredient.ingredient = ingredient  #will assign ingredient_id in join to the ingrdient_id
        recipe_ingredient.save!
      end
      photo_list.each do |photo|
        photos.create!(avatar: photo) #recipe.photos.create()
      end
        update_attributes!(:total_calories => total_calories)
    end
    self
  end



  #for admin
  def self.list_pending_recipes(page_nav:, limit:)
    Recipe.include_photos.pending.order('created_at desc').page_navigation(limit, page_nav)
  end

  
  def approve_recipe
    Recipe.transaction do
      update_attributes!(:approved => true, :rejected=>false)
      self.ingredients.each do |ingredient| 
        ingredient.approve_ingredient
      end
      @@find_user_and_send_mail.call(creator_id, 'recipe_approval_email')
    end 

    self.approved
  end

  def reject_recipe
    update_attributes!(:rejected => true)
    @@find_user_and_send_mail.call(creator_id, 'recipe_rejected_email')
    self.rejected
  end

  def self.get_recipe_meal_class(ingredients_list:)
    meal_class = Ingredient::MEAL_CLASS
    memo = meal_class[meal_class.length-1]
    least_meal_class = ingredients_list.reduce(memo) do |memo, ingre|
      meal_class.index(memo) > meal_class.index(ingre[:meal_class]) ? ingre[:meal_class] : memo
    end
    
  end

  #user recipes related functions

  # Recipe.list recipes function 
  # list_type => order_by_date, order_by_aggregate_ratings, order_by_most_rated
  # all_recipes are approved hence grouped together
  # def self.list_home_page_recipes(list_type:, page_nav:, limit:)
  #   Recipe.include_photos.approved.send(list_type).page_navigation(limit, page_nav)
  # end

   # list_type takes => order_by_date, order_by_aggregate_ratings, order_by_most_rated 
  #status => my_pending_recipes, my_approved_recipes, my_rejected_recipes

  def self.list_recipes(list_type:, page_nav:, limit:,status: nil, creator_id: nil)
    if status&&creator_id
      Recipe.include_photos.send(status,creator_id).send(list_type).page_navigation(limit, page_nav)
    else
      Recipe.include_photos.approved.send(list_type).page_navigation(limit, page_nav)
    end
  end

  def rate_recipe(rater_id:, ratings:)
    Recipe.transaction do
      ((approved == true) && (rater_id != creator_id)) ? (Rating.create!(rater_id: rater_id, recipe_id: id, ratings: ratings)) : false
      update_attributes!(:aggregate_ratings => get_recipe_aggregate_ratings)
    end
  end

  def get_recipe_aggregate_ratings
    rates_hash = ratings.group(:ratings).count
    rates_hash.empty? ? 0 : ((rates_hash.reduce(0) do |memo, pair|
      memo += pair[0] * pair[1]
    end) / (rates_hash.values.reduce(:+)))  
  end

  def get_recipe_details
    return {recipe_content: Recipe.includes(:ratings, :photos, :ingredients).where(:id => id).first,
      ratings_histogram: get_ratings_count_hash}
  end

  def get_ratings_count_hash
    ratings.group(:ratings).count 
  end

  #user specific functions
  # list_type takes => order_by_date, order_by_aggregate_ratings, order_by_most_rated 
  #status => my_pending_recipes, my_approved_recipes, my_rejected_recipes
  # def  self.list_my_recipes(status:, list_type:, creator_id:, page_nav:, limit:)
  #   Recipe.send(status,creator_id).send(list_type).page_navigation(limit, page_nav)
  # end

  def list_rated_users(ratings:)
    Rating.joins('inner join users on users.id = ratings.rater_id').select("users.name as name, users.email as email").where(:recipe_id=>id, :ratings => ratings)
  end

  def self.search(flag:, query:)
    searched_recipes = Recipe.scoped
    searched_recipes = searched_recipes.send flag, query
    searched_recipes
  end


  # def self.list_pending_recipes_test(page_nav:, limit:)
  #   Recipe.includes(:photos).pending.order('created_at desc').page_navigation(limit, page_nav)
  # end
end
