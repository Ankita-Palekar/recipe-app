include RecipesHelper

class Recipe < ActiveRecord::Base
  include SessionsHelper

  belongs_to :user, :foreign_key => 'creator_id'
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

  before_validation :strip_whitespace, :only => [:name, :description]

  scope :free_text, ->(query) {where("name ILIKE ?", "%#{query}%")}
  scope :aggregate_ratings, ->(ratings) {where(aggregate_ratings: ratings)}
  scope :meal_class, ->(meal_class) {where(meal_class: meal_class)}
  scope :calories, -> (calories) {where("total_calories = ? * serves", "#{calories.to_i}")}
  scope :ingredients, ->(query) {joins(:ingredients).where("ingredients.name ILIKE ? AND ingredients.name <> ''", "%#{query}%")}
  scope :approved, -> {where(:approved => true, :rejected => false)}
  scope :order_by_date, -> {order('created_at desc')} 
  scope :order_by_aggregate_ratings, -> {order('aggregate_ratings desc')} 
  scope :ordered_by_count, -> {order("count desc")}
  scope :order_by_most_rated, -> {select("recipes.*, count(ratings.recipe_id) as count").joins(:ratings).group("recipes.id").ordered_by_count}
  scope :pending, -> {where(approved: false, rejected: false)}
  scope :rejected, -> {where(rejected: true)}
  scope :page_navigation, ->(limit, page_nav) {limit(limit).offset((page_nav-1)*limit) }
  scope :ratings_count_hash, -> {ratings.group(:ratings).count }
  scope :photos, -> {joins(:photos)}
  scope :include_photos, -> {includes(:photos)}
 
  def create_recipe(ingredients_list:, photo_list:, current_user:) 
    puts ingredients_list.inspect
    Recipe.transaction do 
      self.meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)
      current_user.recipes << self
      total_calories = 0
      ingredients_list.each do |ingre|
        total_calories += ingre[:quantity].to_i / ingre[:std_quantity].to_i * ingre[:calories_per_quantity].to_i #calculating total calories in recipe
        if ingre.has_key?(:ingredient_id)
          ingredient = Ingredient.find(ingre[:ingredient_id])
        else
          ingredient = current_user.ingredients.build(ingre.except(:quantity))
          ingredient.create_ingredient
        end
        save_recipe_ingredient_join(ingredient, self, ingre[:quantity])
      end
      photo_list.map { |photo| photos.create(avatar: photo)}
      update_attributes(:total_calories => total_calories)
      send_admin_mail('recipe_created_email')
    end
    self
  end

  def update_recipe(photo_list:, ingredients_list:, current_user:)
    Recipe.transaction do 
      self.meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)  if !ingredients_list.empty?
      # update_attributes(params)
      total_calories = 0
      ingredients_list.each do |ingre|
        total_calories += ingre[:quantity].to_i / ingre[:std_quantity].to_i * ingre[:calories_per_quantity].to_i #
        if ingre.has_key?(:ingredient_id)
          ingredient = Ingredient.find(ingre[:ingredient_id])
          ingredient = ingredient.update_ingredient(params: ingre.except(:quantity, :ingredient_id))
        else
          ingredient = current_user.ingredients.build(ingre.except(:quantity))
          ingredient.create_ingredient
        end
        save_recipe_ingredient_join(ingredient, self, ingre[:quantity])
      end
      photo_list.map { |photo| photos.create(avatar: photo)}
      update_attributes(:total_calories => total_calories)
    end
    self
  end

  #for admin
  def self.list_pending_recipes(page_nav:, limit:)
    Recipe.include_photos.pending.order_by_date.page_navigation(limit, page_nav)
  end
  
  def approve_recipe(current_user:)
    Recipe.transaction do
      update_attributes(:approved => true, :rejected=>false) 
      self.ingredients.map {|ingredient| ingredient.approve_ingredient}
      send_approved_or_rejected_mail('recipe_approval_email', current_user)
    end if current_user.is_admin
    self
  end

  def reject_recipe(current_user:)
    begin 
      update_attributes(:rejected => true, :approved => false) 
      user = User.find(self.creator_id)
      send_approved_or_rejected_mail('recipe_rejected_email',user)  
    end  if current_user.is_admin
    self
  end

  def self.get_recipe_meal_class(ingredients_list:)
    meal_class = Ingredient::MEAL_CLASS
    memo = meal_class[meal_class.length-1]
    least_meal_class = ingredients_list.reduce(memo) do |memo, ingre|
      meal_class.index(memo) > meal_class.index(ingre[:meal_class]) ? ingre[:meal_class] : memo
    end   
  end

  # list_type takes => order_by_date, order_by_aggregate_ratings, order_by_most_rated 
  #status => pending, approved, rejected
  def self.list_recipes(list_type:, page_nav:, limit:, status: nil, current_user:nil)
    if status && current_user
      current_user.recipes.include_photos.send(status).send(list_type).order_by_date.page_navigation(limit, page_nav)
    else
      Recipe.include_photos.approved.send(list_type).order_by_date.page_navigation(limit, page_nav)
    end
  end

  def rate_recipe(ratings:, current_user:)
    rate = Rating.find_or_initialize_by_rater_id_and_recipe_id(current_user.id, self.id)
    # rate = current_user.ratings.build
    # rate.recipe = self
    # rate_object = Rating.first_or_initialize(rate)
    transaction do 
      # rate_object.update_attributes(:ratings => ratings)
      rate.update_attributes(:ratings => ratings)
      update_attributes(:aggregate_ratings => get_recipe_aggregate_ratings)
    end if current_user.id != self.creator_id
    rate
  end


  def get_recipe_aggregate_ratings
    rates_hash = ratings.group(:ratings).count
    rates_hash.empty? ? 0 : ((rates_hash.reduce(0) do |memo, pair|
      memo += pair[0] * pair[1]
    end) / (rates_hash.values.reduce(:+)))  
  end

  def get_recipe_details
    return {recipe_content: Recipe.includes(:ratings, :photos, :ingredients).find(self),
      ratings_histogram: get_ratings_count_hash}
  end

  def get_ratings_count_hash
    ratings.group(:ratings).count 
  end

  def list_rated_users(ratings:)
    self.ratings.includes(:user).where(:ratings=> ratings)
  end

  def self.search(query_hash:)
    searched_recipes = Recipe.approved.scoped
    query_hash.each do |flag,query|
      searched_recipes = searched_recipes.send(flag,query)
    end
    searched_recipes
  end

 private
  def strip_whitespace
    self.name = self.name.strip
    self.description = self.description.strip
  end
end
