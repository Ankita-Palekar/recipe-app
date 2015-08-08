class Recipe::RecipesController < ApplicationController
  # GET /recipes
  # GET /recipes.json
  include SessionsHelper
  include RecipesHelper

  # load_and_authorize_resource

  def top_rated_recipes
    @page_header = "Top Rated Recipes"
    @recipe_list = Recipe.list_recipes(list_type:'order_by_aggregate_ratings').paginate(:page => params[:page])
    render '/common/recipe_list'
  end

  
  def most_rated_recipes
    @page_header = "Most Rated Recipes"
    @recipe_list = Recipe.list_recipes(list_type:'order_by_most_rated').paginate(:page => params[:page])
    render '/common/recipe_list'
  end

  
  # GET /recipes/1
  # GET /recipes/1.json
  def show 
    @current_user = current_user
    @recipe_details = Recipe.find(params[:id]).get_recipe_details
    @recipe = @recipe_details[:recipe_content]
    @recipe_ratings_histogram = @recipe_details[:ratings_histogram]
    render '/common/show'
    # respond_to do |format|
      # format.json { render json: @recipe }
    # end
  end

  def search
    render '/common/search'
  end

  def search_recipes
    query_hash = params[:flag]
    query_hash = query_hash.reject {|key, val| val.empty?}
    @page_header = "Search Result"
    @recipe_list =  Recipe.search(:query_hash => query_hash).paginate(:page => params[:page])
    render '/common/search'
  end

  def rated_users_list
    @recipe = Recipe.find(params[:id])
    @users_list = @recipe.list_rated_users(:ratings => params[:ratings])
    render 'common/rated_users_list'
  end
end
