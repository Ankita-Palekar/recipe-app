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
      @recipe = Recipe.find(params[:id]).get_recipe_details
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
    @existing_ingredients_list = Ingredient.getIngredients(@current_user)
    @recipe = Recipe.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @recipe }
    end
  end

  # GET /recipes/1/edit
  def edit
    @existing_ingredients_list = Ingredient.getIngredients(@current_user)
    @recipe_details = Recipe.find(params[:id]).get_recipe_details
    @recipe = @recipe_details[:recipe_content]
  end

  # POST /recipes
  # POST /recipes.json
  def create
    puts params.inspect
    @recipe = Recipe.new(params[:recipe])
    ingredients_list = []


    ingredients_list.push(*params[:ingredient].compact) if !(defined?(params[:ingredient])).nil? 
    ingredients_list.push(*params[:existing_ingredient].compact) if !(defined?(params[:existing_ingredient])).nil?
     
     
    puts "========================"
    photo_list = params[:avatar]
    respond_to do |format|
      if @recipe.create_recipe(ingredients_list: ingredients_list.compact, photo_list: photo_list)
        format.html { redirect_to @recipe, notice: 'Recipe was successfully created.' }
        # format.json { render json: @recipe, status: :created, location: @recipe }
      else
        format.html { render action: "new" }
        # format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /recipes/1
  # PUT /recipes/1.json
  def update
    puts params.inspect
    @recipe = Recipe.find(params[:id])
    respond_to do |format|
      if params[:recipe][:approved] == "true"
        {:status => "successfully approved" }.to_json  if @recipe.approve_recipe
      elsif params[:recipe][:rejected] == "true"
        {:status =>  "sucessfully rejected"}.to_json if @recipe.reject_recipe
      elsif params[:recipe][:ratings] 
         
        if @recipe.rate_recipe(rater_id: @current_user.id, ratings: params[:recipe][:ratings]) 
          
          format.html {redirect_to request.referer, notice: 'successfully rated'}
        else
          format.html {redirect_to request.referer, notice: 'You cannot rate your own recipe'}
        end
      else
        photo_list  =  params[:avatar] ? params[:avatar] : []
        ingredients_list = params[:ingredient]
        respond_to do |format|
          if @recipe.update_recipe(params: params[:recipe], ingredients_list: ingredients_list, photo_list: photo_list)
            format.html { redirect_to @recipe, notice: 'Recipe was successfully edited.'}
          else
            format.html { render action: "new" }
          end
        end
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
