class User::UserRecipesController < ApplicationController
  # GET /recipes
  # GET /recipes.json
include SessionsHelper
include RecipesHelper
  # before_action :authenticate_user! for device

  before_filter :confirm_is_recipe_owner, :only=>[:edit]
  before_filter :confirm_logged_in 
  
  def index
    @recipe_list = show_recipe_list(:status=> 'my_all_recipes', :page_nav => 1, :limit => 10)
    render 'recipe_list'
  end

  # GET /recipes/new
  # GET /recipes/new.json
  def new
    @recipe = Recipe.new
    render "/common/create_recipe"
  end

  # GET /recipes/1/edit
  def edit
    @recipe_details = Recipe.find(params[:id]).get_recipe_details
    @recipe = @recipe_details[:recipe_content]
    render "/common/edit_recipe"
  end

 
  def create
    @current_user = current_user
    @recipe = Recipe.new(params[:recipe])
    params[:ingredient] ||= []
    params[:existing_ingredient] ||= []
    params[:avatar] ||=[]

    respond_to do |format|
      path = "/recipes/#{@recipe.id}"
      
      format.html { redirect_to path, notice: 'Add ingredients' } if (params[:ingredient].to_a.compact + params[:existing_ingredient].to_a.compact).empty?
      format.html { redirect_to path, notice: 'Add images' } if (params[:avatar].to_a).empty?
      @recipe.create_recipe(ingredients_list: (params[:ingredient].compact.to_a + params[:existing_ingredient].compact.to_a),current_user: @current_user, photo_list: params[:avatar].compact)
      if @recipe.persisted?
        format.html { redirect_to path, notice: 'Recipe created successfully' }
        format.json { render json: @recipe, status: :created, location: @recipe }
      else
        notice = @recipe.errors
        format.html { redirect_to path, notice: notice }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  

  def rate_recipe
    @current_user = current_user
    puts params.inspect
    @recipe = Recipe.find(params[:recipe][:id]) 
    respond_to do |format|
      @rate = @recipe.rate_recipe(current_user: @current_user, ratings: params[:recipe][:ratings])
      puts @rate.inspect
      notice = {}
      notice[:message] = @rate.persisted? ? "successfully rated" : "could not rate"
      format.html {redirect_to @recipe , notice: notice}
      format.json {render json: notice, status: :created}
    end
  end

  # PUT /recipes/1
  # PUT /recipes/1.json
  def update
    @current_user = current_user
    @recipe =  Recipe.find(params[:id])
    params[:ingredient]||=[]
    params[:existing_ingredient]||=[]
    params[:avatar]||=[]
    respond_to do |format|  
      @recipe.update_attributes(params[:recipe])
      @recipe.update_recipe(ingredients_list: (params[:ingredient].compact.to_a + params[:existing_ingredient].compact.to_a), photo_list:params[:avatar], current_user:@current_user)
      if @recipe.valid?
        path = "/recipes/#{@recipe.id}"  #@@TODO find dynamic instad of hard coding
        puts path
        format.html { redirect_to path, notice: 'Recipe was successfullt edited'}
      else
        format.html { render action: "edit" }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end   
    end
  end

  def my_pending_recipes
    @page_header = "My Pending Recipes"
    @recipe_list = Recipe.list_recipes(list_type:'order_by_date', status: 'pending', page_nav:1, limit:100, current_user: @current_user)
    render '/common/recipe_list'
  end

  def my_rejected_recipes
    @page_header = "My Rejected Recipes"
    @recipe_list = Recipe.list_recipes(list_type:'order_by_date',status: 'rejected', page_nav:1, limit:100, current_user: @current_user)
    render '/common/recipe_list'
  end

  def my_top_rated_recipes
    @page_header = "My Top Rated Recipes"
    @recipe_list = Recipe.list_recipes(list_type:'order_by_aggregate_ratings',status: 'approved', page_nav:1, limit:100, current_user: @current_user)
    render '/common/recipe_list'
  end

  def my_most_rated_recipes
    @page_header = "My Most Rated Recipes"
    @recipe_list = Recipe.list_recipes(list_type:'order_by_most_rated',status: 'approved', page_nav:1, limit:100, current_user: @current_user)
    render '/common/recipe_list'
  end

  def my_approved_recipes
    @page_header = "My Approved Recipes"
    @recipe_list = Recipe.list_recipes(list_type:'order_by_date',status: 'approved', page_nav:1, limit:100, current_user: @current_user)
    render '/common/recipe_list'
  end


  protected

  def confirm_is_recipe_owner
    @recipe = Recipe.find(params[:id])
    @current_user = current_user
    puts @current_user.inspect
    unless @recipe.creator_id == @current_user.id
      redirect_to '/caution'
      return false
    else
      return true
    end
  end

  def confirm_logged_in
    unless logged_in?
      # puts "you are not allowed"
      flash[:notice] = 'login before carying out any action'
      redirect_to new_user_session_path
      return false
    else
      return true
    end
  end


end
