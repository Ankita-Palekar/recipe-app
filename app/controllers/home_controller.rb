class HomeController < ApplicationController
	def index
		@top_rated_recipes = Recipe.list_home_page_recipes(list_type: 'order_by_aggregate_ratings', page_nav: 1, limit: 5)
		@most_rated_recipes = Recipe.list_home_page_recipes(list_type: 'order_by_most_rated', page_nav: 1, limit: 5)
		@latest_recipes  = Recipe.list_home_page_recipes(list_type: 'order_by_date', page_nav: 1, limit: 5)
		respond_to do |format|
		  format.html
		end		
	end
end
