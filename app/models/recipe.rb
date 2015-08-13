class Recipe < ActiveRecord::Base
  # REVIEW: recipe <=> creator association
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

  scope :free_text, ->(query) {where("name ILIKE ?", "%#{query}%")}
  scope :aggregate_ratings, ->(ratings) {where(aggregate_ratings: ratings)}
  scope :meal_class, ->(meal_class) {where(meal_class: meal_class)}
  # REVIEW: Why is this a search by exact calories? It was supposed to be a
  # range search
  scope :calories, -> (calories) {where("total_calories = ? * serves", "#{calories.to_i}")}

  # REVIEW: search by multiple ingredients is required
  scope :ingredients, ->(query) {joins(:ingredients).where("ingredients.name ILIKE ? AND ingredients.name <> ''", "%#{query}%")}
  scope :approved, -> {where(:approved => true, :rejected => false)}
  scope :order_by_date, -> {order('created_at desc')} 
  scope :order_by_aggregate_ratings, -> {order('aggregate_ratings desc')} 
  scope :ordered_by_count, -> {order("count desc")}
  scope :order_by_most_rated, -> {select("recipes.*, count(ratings.recipe_id) as count").joins(:ratings).group("recipes.id").ordered_by_count}
  scope :pending, -> {where(approved: false, rejected: false)}
  scope :rejected, -> {where(rejected: true)}
  # scope :page_navigation, ->(limit, page_nav) {limit(limit).offset((page_nav-1)*limit) }
  scope :ratings_count_hash, -> {ratings.group(:ratings).count }
  scope :photos, -> {joins(:photos)}
  scope :include_photos, -> {includes(:photos)}
 
  def save_recipe_ingredient_join(ingredient, recipe, quantity)
    # recipe_ingredient = recipe.recipe_ingredients.build
    # recipe_ingredient.ingredient = ingredient  #will assign ingredient_id in join to the ingrdient_id
    # rec_ing = RecipeIngredient.first_or_initialize(recipe_ingredient) 
    # rec_ing.update_attributes!(quantity: quantity)
    
    rec_ing = RecipeIngredient.where(:ingredient_id => ingredient.id, :recipe_id => recipe.id)
    rec_ing = RecipeIngredient.find_or_initialize_by_ingredient_id_and_recipe_id(ingredient.id, recipe.id)
    rec_ing.update_attributes(:quantity => quantity)
  end

  def send_admin_mail(function_name)
    admin_list  = User.get_admins 
    admin_list.each do |admin|
      user = User.find_by_id(admin.id)
      user.admin_notify_email(:function_name => function_name)
    end
  end

  def send_approved_or_rejected_mail(function_name, creator)
    user = User.find(creator.id)
    user.user_notify_email(:function_name => function_name)
  end


  def add_recipe_photos(photo_list, recipe)
    photo_list.each do |photo|
      photo = Photo.find(photo)
      photo.recipe = self
      photo.save!
    end
  end

  def add_recipe_ingredients(ingredients_list, recipe, current_user)
    total_calories = 0
    ingredients_list.each do |ingre|
      total_calories += ingre[:quantity].to_i / ingre[:std_quantity].to_i * ingre[:calories_per_quantity].to_i #calculating total calories in recipe
      if ingre.has_key?(:ingredient_id)
        ingredient = Ingredient.find(ingre[:ingredient_id])
        ingredient = ingredient.update_ingredient(params: ingre.except(:quantity, :ingredient_id))
      else
        ingredient = current_user.ingredients.build(ingre.except(:quantity))
        ingredient.create_ingredient
      end
      save_recipe_ingredient_join(ingredient, recipe, ingre[:quantity])
    end
    total_calories
  end


  def create_recipe(ingredients_list:, photo_list:, current_user:) 
    Recipe.transaction do 
      self.meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)
      # REVIEw: Why is the following line required?
      self.creator = current_user
      # current_user.recipes << self
      total_calories = add_recipe_ingredients(ingredients_list, self, current_user)
      add_recipe_photos(photo_list, self)
      # REVIEW: What will happen if there is an error in creating the photo?
      # REVIEW: What will happen if there is an error in updating the total_calories?
      # photo_list.map { |photo| photos.create(avatar: photo)}
      update_attributes!(:total_calories => total_calories)
      send_admin_mail('recipe_created_email')
    end
    self
  end

  # REVIEW: Why is there code duplication in create & update?
  def update_recipe(photo_list:, ingredients_list:, current_user:)
    Recipe.transaction do 
      self.meal_class = Recipe.get_recipe_meal_class(ingredients_list: ingredients_list)  if !ingredients_list.empty?
      total_calories =  add_recipe_ingredients(ingredients_list, self, current_user)
      add_recipe_photos(photo_list, self)
      update_attributes!(:total_calories => total_calories)
    end
    self
  end

  #for admin
  def self.list_pending_recipes
    Recipe.include_photos.pending.order_by_date 
  end
  
  # REVIEW: what happens if user is not admin? Read ActiveRecord::Error class
  # and use it. You can use it for your own custom validation messages as
  # well.
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
      current_user.recipes.include_photos.send(status).send(list_type).order_by_date
    elsif other_user && status
      other_user.recipes.include_photos.send(status).send(list_type)
    else
      Recipe.include_photos.approved.send(list_type).order_by_date
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
    self.ratings.includes(:rater).where(:ratings=> ratings)
  end

  def self.search(query_hash:)
    searched_recipes = Recipe.approved.scoped if !query_hash.empty?
    flag_check = ["ingredients", "meal_class", "calories", "free_text", "aggregate_ratings"] # tie it in your head always check if data is coming fo user beofre executing
    
    query_hash.each do |flag,query|
      # REVIEW: NEVER EVER execute untrusted code coming from user-input.
      # Either restructure this search completely OR create a whitelist of
      # permissible values for 'flag'
      searched_recipes = searched_recipes.send(flag,query) if flag_check.include? flag
    end 
    searched_recipes ||=[]
  end
 private
  def strip_whitespace
    self.name = self.name.strip
    self.description = self.description.strip
  end
end
