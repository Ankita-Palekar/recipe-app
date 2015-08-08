class HomeController < ApplicationController
	def index
		@top_rated_recipes = Recipe.list_recipes(list_type: 'order_by_aggregate_ratings').paginate(:page => params[:page])
		@most_rated_recipes = Recipe.list_recipes(list_type: 'order_by_most_rated').paginate(:page => params[:page])
		@latest_recipes  = Recipe.list_recipes(list_type: 'order_by_date').paginate(:page => params[:page])
		respond_to do |format|
		  format.html
		end		
	end
end
