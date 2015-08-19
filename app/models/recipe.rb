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
  # where("to_tsvector(title) || to_tsvector(description) @@ to_tsquery('#{search_terms}')")

  scope :free_text, ->(query) {where("to_tsvector(name) @@ plainto_tsquery(:q) OR to_tsvector(description)  @@ plainto_tsquery(:q)", q: query)}
  scope :aggregate_ratings, ->(ratings) {where(aggregate_ratings: ratings)}
  scope :meal_class, ->(meal_class) {where(meal_class: meal_class)}
  scope :calories, -> (calories) {where(:total_calories => (calories[0].to_f)..(calories[1].to_f))}
  # scope :ingredients, ->(query) {joins(:ingredients).where(query)}
  scope :ingredients, ->(query) {joins(:ingredients).where("to_tsvector('english', ingredients.name)  @@ plainto_tsquery(:q)", q: query)}
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

  # def initialize
  #   Recipe.start_delete_unwanted_recipe_images
  # end

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


  # def delete_unwanted_recipe_images
  #   Photo.where(:recipe_id => nil).destroy_all
  #   self.delay(:run_at => 20.minute.from_now).delete_unwanted_recipe_images
  # end

  # def self.start_delete_unwanted_recipe_images
  #   new.delete_unwanted_recipe_images
  # end

  # handle_asynchronously :delete_unwanted_recipe_images

  def add_recipe_ingredients(ingredients_list, recipe, current_user)
    total_calories = 0
    ingredients_list.each do |ingre|
      total_calories += ingre[:quantity].to_f / ingre[:std_quantity].to_f * ingre[:calories_per_quantity].to_f #calculating total calories in recipe
      if ingre.has_key?(:ingredient_id)
        ingredient = Ingredient.find(ingre[:ingredient_id])
        ingredient = ingredient.update_ingredient(params: ingre.except(:quantity, :ingredient_id))
      else
        ingredient = current_user.ingredients.build(ingre.except(:quantity))
        ingredient = ingredient.create_ingredient
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
      self.save
      # current_user.recipes << self
      total_calories = add_recipe_ingredients(ingredients_list, self, current_user)
      add_recipe_photos(photo_list, self)
      # REVIEW: What will happen if there is an error in creating the photo?
      # REVIEW: What will happen if there is an error in updating the total_calories?
      # photo_list.map { |photo| photos.create(avatar: photo)}
      update_attributes!(:total_calories => total_calories)
      send_admin_mail('recipe_created_email', self, current_user)
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
      if current_user.is?(:admin)
        update_attributes(:approved => true, :rejected=>false) 
        self.ingredients.map {|ingredient| ingredient.approve_ingredient}
        send_approved_or_rejected_mail('recipe_approval_email', self, current_user)
      else 
        self.errors = "only admin can approve recipe"
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
        self.errors = "only admin can reject recipe"
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
    return {recipe_content: Recipe.includes(:ratings, :photos, :ingredients, :creator).find(self),
      ratings_histogram: get_ratings_count_hash}
  end

  def get_ratings_count_hash
    ratings.group(:ratings).count 
  end

  def list_rated_users(ratings:)
    self.ratings.includes(:rater).where(:ratings=> ratings)
  end

  def self.search(query_hash:)
    puts "============================ SEARCH RESULT ==============================="
    searched_recipes = Recipe.approved.scoped if !query_hash.empty?
    flag_check = ["ingredients", "meal_class", "calories", "free_text", "aggregate_ratings"]  
    


    query_hash.each do |flag,query|
      # if flag == 'ingredients'
      #   query = query.split(' ') 
      #   query = query.reduce('') { |memo, ele| memo += " ingredients.name ILIKE '%#{ele}%' OR" }
      #   query = query.strip
      #   query = query[/(.*)\s/,1]
      #   query += " AND ingredients.name <> '' "
      # end
      
      if flag== ('ingredients' || "free_text")
        
      end
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
