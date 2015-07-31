class HomeController < ApplicationController
	def index
		@top_rated_recipes = Recipe.list_recipes(list_type: 'order_by_aggregate_ratings', page_nav: 1, limit: 10)
		@most_rated_recipes = Recipe.list_recipes(list_type: 'order_by_most_rated', page_nav: 1, limit: 10)
		@latest_recipes  = Recipe.list_recipes(list_type: 'order_by_date', page_nav: 1, limit: 10)
		respond_to do |format|
		  format.html
		end		
	end
end
