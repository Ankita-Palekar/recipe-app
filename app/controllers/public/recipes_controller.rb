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
      # @recipe_list = show_recipe_list(:status=> params[:id], :page_nav => 1, :limit => 10)
      # render 'recipe_list'
    end   
  end


  def top_rated_recipe
    @recipe_list =  list_recipes(list_type: 'order_by_aggregate_ratings', page_nav:1, limit:100)
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
