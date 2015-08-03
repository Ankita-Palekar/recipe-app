class RecipesController < ApplicationController
  # GET /recipes
  # GET /recipes.json
include SessionsHelper
include RecipesHelper

  before_filter :confirm_is_recipe_owner, :only=>[:edit]

  def confirm_is_recipe_owner
    @recipe = Recipe.find(params[:id])
    
    unless @recipe.creator_id == @current_user.id
      redirect_to '/caution'
      return false
    else
      return true
    end
  end


  def index
    @recipe_list = show_recipe_list(:status=> 'my_all_recipes', :page_nav => 1, :limit => 10)
    render 'recipe_list'
  end

  # GET /recipes/1
  # GET /recipes/1.json
  def show
    if params[:id].to_i > 0
      @recipe_details = Recipe.find(params[:id]).get_recipe_details
      @recipe = @recipe_details[:recipe_content]
      @recipe_ratings_histogram = @recipe_details[:ratings_histogram]


      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @recipe }
      end
    else
      @recipe_list = show_recipe_list(:status=> params[:id], :page_nav => 1, :limit => 10)
      render 'recipe_list'
    end   
  end

  # GET /recipes/new
  # GET /recipes/new.json
  def new
    @recipe = Recipe.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @recipe }
    end
  end

  # GET /recipes/1/edit
  def edit
    @recipe_details = Recipe.find(params[:id]).get_recipe_details
    @recipe = @recipe_details[:recipe_content]
  end

 
  def create
    @current_user = current_user
    @recipe = Recipe.new(params[:recipe])
    params[:ingredient] ||= []
    params[:existing_ingredient] ||= []
    params[:avatar] ||=[]

    respond_to do |format|
      format.html { redirect_to new_recipe_path, notice: 'Add ingredients' } if (params[:ingredient].to_a.compact + params[:existing_ingredient].to_a.compact).empty?
      format.html { redirect_to new_recipe_path, notice: 'Add images' } if (params[:avatar].to_a).empty?
      @recipe.create_recipe(ingredients_list: (params[:ingredient].compact.to_a + params[:existing_ingredient].compact.to_a),current_user: @current_user, photo_list: params[:avatar].compact)
      if @recipe.persisted?
        format.html { redirect_to @recipe, notice: 'Recipe created successfully' }
        format.json { render json: @recipe, status: :created, location: @recipe }
      else
        format.html { render action: "new" }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end


  def approve_recipe
    @current_user = current_user
    @recipe = Recipe.find(params[:recipe][:id]) 
    respond_to do |format|
      begin
        notice = {}
        notice[:message] = @recipe.approve_recipe(current_user: @current_user) ? 'successfully approved' : 'could not be approved'
        format.html {redirect_to @recipe , notice: notice}
        format.json { render json: @recipe , notice: notice} 

      end if params[:recipe][:approved] == "true"
    end
  end

  def reject_recipe
    @current_user = current_user
    @recipe = Recipe.find(params[:recipe][:id]) 
    respond_to do |format|
      begin
        notice = {}
        notice[:message] = @recipe.reject_recipe(current_user: @current_user) ? 'successfully rejected' : 'could not be rejected'
        format.html {redirect_to @recipe , notice: notice}
        format.json { render json: @recipe , notice: notice}  
      end if(params[:recipe][:rejected] == "true")
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
        format.html { redirect_to @recipe, notice: 'Recipe was successfully edited'}
      else
        format.html { render action: "edit" }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end   
    end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.json
  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    respond_to do |format|
      format.html { redirect_to recipes_url }
      format.json { head :no_content }
    end
  end

  def searchrecipes
  # puts params.inspect
    @recipe_list =  Recipe.search(:flag => params[:flag], :query => params[:query])
    render 'search'
  end

  def rated_users_list
    @recipe = Recipe.find(params[:id])
    @users_list = @recipe.list_rated_users(:ratings => params[:ratings])
  end
end
