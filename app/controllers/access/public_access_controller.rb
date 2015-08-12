module Access
	class PublicAccessController < ApplicationController
		def show_top_rated_recipes
			@page_title = "Top Rated Recipes"
			@recipe_list = list_recipes(list_type:'order_by_aggregate_ratings', page_nav: 1, limit: 10)
		end
		def show_most_rated_recipes
			@page_title = "Most Rated Recipes"
			@recipe_list = list_recipes(list_type:'order_by_most_rated ', page_nav: 1, limit: 10)
		end
	end
end