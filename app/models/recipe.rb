class Recipe < ActiveRecord::Base
  belongs_to :creator, :foreign_key => 'creator_id', :class_name => User
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
  self.per_page = 10 #for pagination
  scope :recipe, ->(query) {where("to_tsvector(recipes.name) || to_tsvector(description)  @@ plainto_tsquery(:q)", q: query)}
  scope :aggregate_ratings, ->(ratings) {where(aggregate_ratings: ratings)}
  scope :meal_class, ->(meal_class) {where(meal_class: meal_class)}
  scope :calories, -> (calories) {where(:total_calories => (calories[0].to_f)..(calories[1].to_f))}
  scope :ingredients, ->(query) {joins(:ingredients).where("to_tsvector(ingredients.name)  @@ plainto_tsquery(:q)", q: query)}
  scope :approved, -> {where(:approved => true, :rejected => false)}
  scope :order_by_date, -> {order('created_at desc')} 
  scope :order_by_aggregate_ratings, -> {order('aggregate_ratings desc')} 
  scope :ordered_by_count, -> {order("count desc")}
  scope :order_by_most_rated, -> {select("recipes.*, count(ratings.recipe_id) as count").joins(:ratings).group("recipes.id").ordered_by_count}
  scope :pending, -> {where(approved: false, rejected: false)}
  scope :rejected, -> {where(rejected: true)}
  scope :ratings_count_hash, -> {ratings.group(:ratings).count }
  scope :photos, -> {joins(:photos)}
  scope :include_photos, -> {includes(:photos)}
  scope :include_creator, -> {includes(:creator)}
   
  def save_recipe_ingredient_join(ingredient, recipe, quantity)
    rec_ing = RecipeIngredient.where(:ingredient_id => ingredient.id, :recipe_id => recipe.id)
    rec_ing = RecipeIngredient.find_or_initialize_by_ingredient_id_and_recipe_id(ingredient.id, recipe.id)
    rec_ing.update_attributes(:quantity => quantity, :recipe_id => recipe.id)
  end

  def send_admin_mail(function_name, recipe, creator)
    admin_list  = User.get_admins 
    admin_list.each do |admin|
      user = User.find_by_id(admin.id)
      user.admin_notify_email(:function_name => function_name, :recipe => recipe, :user => creator)
    end
  end

  def send_approved_or_rejected_mail(function_name, recipe, admin)
    user = User.find(recipe.creator_id)
    user.user_notify_email(:function_name => function_name,:recipe => recipe, :user => user)
  end

  def add_recipe_photos(photo_list, recipe)
    photo_list.each do |photo|
      photo = Photo.find(photo)
      photo.recipe = self
      photo.save!
    end
  end
 
  def self.delete_unwanted_recipe_images
    puts "---------- job deleting unwanted recipes ---------"
    Photo.where(:recipe_id => nil).destroy_all
  end
  # handle_asynchronously :delete_unwanted_recipe_images, :run_at => Proc.new { 5.minutes.from_now }
  
  def calculate_total_calories(ingredients_list)
    total_calories = 0
    ingredients_list.each do |ingre|
      total_calories +=  (ingre[:std_quantity].to_f != 0) ? ((ingre[:quantity].to_f / ingre[:std_quantity].to_f) * ingre[:calories_per_quantity].to_f) : 0 
    end
    total_calories
  end

  def add_recipe_ingredients(ingredients_list, recipe, current_user)
    total_calories = 0
    ingredients_list.each do |ingre|
      if !ingre[:id] == 0
        ingredient = Ingredient.find(ingre[:id])
        ingredient = ingredient.update_ingredient(params: ingre.except(:quantity, :id, :creator))
      else
        ingredient = current_user.ingredients.build(ingre.except(:quantity))
        ingredient = ingredient.create_ingredient
      end
      save_recipe_ingredient_join(ingredient, recipe, ingre[:quantity])
    end
  end

  def create_recipe(ingredients_list:, photo_list:, current_user:) 
    Recipe.transaction do 
      self.meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)
      self.creator = current_user
      self.save
      add_recipe_ingredients(ingredients_list, self, current_user)
      total_calories = calculate_total_calories(ingredients_list)
      add_recipe_photos(photo_list, self)
      update_attributes!(:total_calories => total_calories)
      send_admin_mail('recipe_created_email', self, current_user)
    end
    self
  end

  def update_recipe(photo_list:, ingredients_list:, current_user:)
    Recipe.transaction do 
      self.meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)  if !ingredients_list.empty?
      add_recipe_ingredients(ingredients_list, self, current_user)
      total_calories = calculate_total_calories(ingredients_list)
      add_recipe_photos(photo_list, self)
      update_attributes!(:total_calories => total_calories)
    end
    self
  end

  def self.list_pending_recipes
    Recipe.include_photos.pending.order_by_date 
  end
  
  def approve_recipe(current_user:)
    Recipe.transaction do
      if current_user.is?(:admin)
        update_attributes(:approved => true, :rejected=>false) 
        self.ingredients.map {|ingredient| ingredient.approve_ingredient}
        send_approved_or_rejected_mail('recipe_approval_email', self, current_user)
      else 
        self.errors[:base] = "only admin can approve recipe"
      end
    end 
    self
  end

  def reject_recipe(current_user:)
    begin 
      if current_user.is?(:admin)
        update_attributes(:rejected => true, :approved => false) 
        user = User.find(self.creator_id)
        send_approved_or_rejected_mail('recipe_rejected_email', self, current_user)  
      else
        self.errors[:base] = "only admin can reject recipe"
      end
    end  
    self
  end

  def destroy_recipe_ingredient(ingredient_id:, current_user:)
    ((self.creator_id == current_user.id )|| (current_user.is? :admin)) ? self.recipe_ingredients.find_by_ingredient_id(ingredient_id).delete : (self.errors = "You are not the owner to delete this")
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
  # def self.list_recipes(list_type:, page_nav:, limit:, status: nil, current_user:nil)
  
  def self.list_recipes(list_type:, status: nil, current_user:nil, other_user: nil)
    
    if status && current_user
      current_user.recipes.include_photos.include_creator.send(status).send(list_type).order_by_date
    elsif other_user && status
      other_user.recipes.include_photos.include_creator.send(status).send(list_type)
    else
      Recipe.include_photos.approved.send(list_type).order_by_date
    end
  end

  def rate_recipe(ratings:, current_user:)
    rate = Rating.find_or_initialize_by_rater_id_and_recipe_id(current_user.id, self.id)
    transaction do 
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
    return {recipe_content: Recipe.includes(:ratings, :photos, :ingredients, :creator, :recipe_ingredients).find(self),
    ratings_histogram: get_ratings_count_hash}
  end

  def get_ratings_count_hash
    ratings.group(:ratings).count 
  end

  def list_rated_users(ratings:)
    self.ratings.includes(:rater).where(:ratings=> ratings)
  end

  def self.search(query_hash:)
    #free_text has been replaced by recipe
    searched_recipes = Recipe.approved.scoped if !query_hash.empty?
    flag_check = ["ingredients", "meal_class", "calories", "recipe", "aggregate_ratings"]  
    query_hash.each do |flag,query|
      searched_recipes = searched_recipes.send(flag,query) if flag_check.include? flag 
    end 
    puts searched_recipes
    puts searched_recipes.inspect
    searched_recipes ||=[]
  end

 private
  def strip_whitespace
    self.name = self.name.strip
    self.description = self.description.strip
  end
end
