class RecipesController < ApplicationController
  # GET /recipes
  # GET /recipes.json
include SessionsHelper
include RecipesHelper
  def index
    @user = User.find_by_id(session[:user_id]) 
    @recipes = Recipe.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @recipes }
    end
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
    @recipe = Recipe.find(params[:id])
  end

  # POST /recipes
  # POST /recipes.json
  def create
    # puts params.inspect
    @recipe = Recipe.new(params[:recipe])
    ingredients_list = (params[:ingredient] + params[:existing_ingredient]).uniq
    photo_list = params[:avatar]
    respond_to do |format|
      if @recipe.create_recipe(ingredients_list: ingredients_list, photo_list: photo_list)
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
    @recipe = Recipe.find(params[:id])
    respond_to do |format|
      if params[:recipe][:approved] == "true"
        {:status => "successfully approved" }.to_json  if @recipe.approve_recipe
      elsif params[:recipe][:rejected] == "true"
        {:status =>  "sucessfully rejected"}.to_json if @recipe.reject_recipe
      elsif params[:recipe][:ratings] 
        # @recipe.rate_recipe(rater_id: @current_user.id, ratings: params[:recipe][:ratings])
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
end
