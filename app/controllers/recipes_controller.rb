class RecipesController < ApplicationController
  # GET /recipes
  # GET /recipes.json
include SessionsHelper
include RecipesHelper


  def top_rated_recipes
    @page_header = "Top Rated Recipes"
    @recipe_list = Recipe.list_recipes(list_type:'order_by_aggregate_ratings', page_nav:1, limit:100)
    render '/common/recipe_list'
  end


  def most_rated_recipes
    @page_header = "Most Rated Recipes"
    @recipe_list = Recipe.list_recipes(list_type:'order_by_most_rated', page_nav:1, limit:100)
    render '/common/recipe_list'
  end

  


  # GET /recipes/1
  # GET /recipes/1.json
  def show 
    @current_user = current_user
    @recipe_details = Recipe.find(params[:id]).get_recipe_details
    @recipe = @recipe_details[:recipe_content]
    @recipe_ratings_histogram = @recipe_details[:ratings_histogram]
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @recipe }
    end
  end

  def search
    render '/common/search'
  end

  def searchrecipes
    @page_header = "Search Result"
    @recipe_list =  Recipe.search(:flag => params[:flag], :query => params[:query])
    puts @recipe_list.inspect
    render '/common/search'
  end

  def rated_users_list
    @recipe = Recipe.find(params[:id])
    @users_list = @recipe.list_rated_users(:ratings => params[:ratings])
  end


 
  # # GET /recipes/1/edit
  # def edit
  #   @recipe_details = Recipe.find(params[:id]).get_recipe_details
  #   @recipe = @recipe_details[:recipe_content]
  #   render "/common/edit_recipe"
  # end

  
  # def create
  #   @current_user = current_user
  #   @recipe = Recipe.new(params[:recipe])
  #   params[:ingredient] ||= []
  #   params[:existing_ingredient] ||= []
  #   params[:avatar] ||=[]

  #   respond_to do |format|
  #     format.html { redirect_to({action: "new"}, {notice: 'Add ingredients'})} if (params[:ingredient].to_a.compact + params[:existing_ingredient].to_a.compact).empty?
  #     format.html { redirect_to({action: "new"},{notice: 'Add images'})} if (params[:avatar].to_a).empty?
  #     @recipe.create_recipe(ingredients_list: (params[:ingredient].compact.to_a + params[:existing_ingredient].compact.to_a),current_user: @current_user, photo_list: params[:avatar].compact)
  #     if @recipe.persisted?
  #       format.html { redirect_to({action: "show", id: @recipe.id}, {notice: 'Recipe created successfully'})}
  #       format.json { render json: @recipe, status: :created, location: @recipe }
  #     else
  #       format.html { render action: "new" }
  #       format.json { render json: @recipe.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # def rate_recipe
  #   @current_user = current_user
  #   puts params.inspect
  #   @recipe = Recipe.find(params[:recipe][:id]) 
  #   respond_to do |format|
  #     @rate = @recipe.rate_recipe(current_user: @current_user, ratings: params[:recipe][:ratings])
  #     puts @rate.inspect
  #     notice = {}
  #     notice[:message] = @rate.persisted? ? "successfully rated" : "could not rate"
  #     format.html {redirect_to({action: "show", id: @recipe.id}, {notice: notice})}
  #     format.json {render json: notice, status: :created}
  #   end
  # end

  # # PUT /recipes/1
  # # PUT /recipes/1.json
  # def update
  #   @current_user = current_user
  #   @recipe =  Recipe.find(params[:id])
  #   params[:ingredient]||=[]
  #   params[:existing_ingredient]||=[]
  #   params[:avatar]||=[]
  #   respond_to do |format|  
  #     @recipe.update_attributes(params[:recipe])
  #     @recipe.update_recipe(ingredients_list: (params[:ingredient].compact.to_a + params[:existing_ingredient].compact.to_a), photo_list:params[:avatar], current_user:@current_user)
  #     if @recipe.valid?
  #       format.html { redirect_to({action: "show", id: @recipe.id}, {notice: 'Recipe was successfullt edited'})}
  #     else
  #       format.html { render action: "edit" }
  #       format.json { render json: @recipe.errors, status: :unprocessable_entity }
  #     end   
  #   end
  # end

  # def approve_recipe
  #   @current_user = current_user
  #   @recipe = Recipe.find(params[:recipe][:id]) 
  #   respond_to do |format|
  #     begin
  #       notice = {}
  #       notice[:message] = @recipe.approve_recipe(current_user: @current_user) ? 'successfully approved' : 'could not be approved'
  #       format.html { redirect_to({action: "show", id: @recipe.id}, {notice: notice})}
  #       format.json { render json: @recipe , notice: notice} 
  #     end if params[:recipe][:approved] == "true"
  #   end
  # end

  # def reject_recipe
  #   @current_user = current_user
  #   @recipe = Recipe.find(params[:recipe][:id]) 
  #   respond_to do |format|
  #     begin
  #       notice = {}
  #       notice[:message] = @recipe.reject_recipe(current_user: @current_user) ? 'successfully rejected' : 'could not be rejected'
  #       format.html { redirect_to({action: "show", id: @recipe.id}, {notice: notice})}
  #       format.json { render json: @recipe , notice: notice}  
  #     end if(params[:recipe][:rejected] == "true")
  #   end
  # end

  # def my_pending_recipes
  #   @recipe_list = Recipe.list_recipes(list_type:'order_by_date', status: 'pending', page_nav:1, limit:100, current_user: @current_user)
  #   render '/common/recipe_list'
  # end

  # def my_rejected_recipes
  #   @recipe_list = Recipe.list_recipes(list_type:'order_by_date',status: 'rejected', page_nav:1, limit:100, current_user: @current_user)
  #   render '/common/recipe_list'
  # end

  # def my_top_rated_recipes
  #   @recipe_list = Recipe.list_recipes(list_type:'order_by_aggregate_ratings',status: 'approved', page_nav:1, limit:100, current_user: @current_user)
  #   render '/common/recipe_list'
  # end

  # def my_most_rated_recipes
  #   @recipe_list = Recipe.list_recipes(list_type:'order_by_most_rated',status: 'approved', page_nav:1, limit:100, current_user: @current_user)
  #   render '/common/recipe_list'
  # end

  # def my_approved_recipes
  #   @recipe_list = Recipe.list_recipes(list_type:'order_by_date',status: 'approved', page_nav:1, limit:100, current_user: @current_user)
  #   render '/common/recipe_list'
  # end

end
