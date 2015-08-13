module RecipesHelper

	# def show_admin_pending_recipes(page_nav:, limit:)
	# 	admin_pending_recipes =  Recipe.list_pending_recipes(page_nav: page_nav, limit: limit)
	#  	html_code = make_admin_html_code(admin_pending_recipes)
	#  	html_code
	# end
	# 
	# 

	def already_rated?(recipe)
		recipe.ratings.where(:rater_id => current_user.id)
	end
	def is_recipe_owner?(recipe)
		(current_user.id == recipe.creator_id)
	end

	def get_existing_ingredient_list
		@current_user = current_user
		Ingredient.getIngredients(@current_user)		
	end

	def generate_approved_button(recipe)
		approve_common_class = "btn btn-success"
		approve_class_name = recipe.approved ? "disabled" : "approve-recipe"
		approve_text =  recipe.approved ? "Approved": "Approve"
		approve_button = link_to(approve_text, "#", {:class=> [approve_class_name, approve_common_class], :'data-rec-id' => recipe.id})
	end

	def generate_rejected_button(recipe)
		reject_common_class = "btn  btn-danger "
		reject_class_name = recipe.rejected ? "disabled" : "reject-recipe"
		reject_text = recipe.rejected ? "Rejected" : "Reject"
		reject_button = link_to(reject_text, "#", {:class=> [reject_common_class,reject_class_name], :'data-rec-id' => recipe.id})
	end

	def print_approve_reject_button(recipe)
		button =""
		button = generate_approved_button(recipe) + generate_rejected_button(recipe) if !recipe.approved && ! recipe.rejected #pending
		# button = generate_approved_button(recipe) if recipe.approved && !recipe.rejected 
		# button = generate_rejected_button(recipe) if recipe.rejected && !recipe.approved
		return button.html_safe if (is_admin?)
	end

	def generate_rate_button(recipe)
		approve_common_class = "btn btn-primary rate-recipe"
		rate_text =already_rated?(recipe) ? "You already rated this" : "Rate this recipe"
		approve_button = link_to(rate_text,"#", {:class=> [approve_common_class], :'data-rec-id' => recipe.id})
	end

	def print_rate_button(recipe)
 		 
 		button =""
		button = generate_rate_button(recipe) if (user_signed_in? && !is_recipe_owner?(recipe) && recipe.approved)
		
		puts button.inspect

		return button.html_safe
	end

	def print_recipe_edit_content(recipe)
		link = ""
		link = link_to("", edit_recipe_path(recipe) , :class => "fa fa-pencil fa-3x edit recipe-edit") if is_recipe_owner?(recipe)
		link.html_safe
	end

	def print_admin_pending_recipe_link
		content_tag(:li, link_to("Admin Pending Recipes", admin_pending_recipes_path)) if user_signed_in? && current_user.is?(:admin) 
	end

	def print_login_link
		content_tag(:li, link_to("Login", new_user_session_path)) if !user_signed_in?
	end

	def list_approve_reject_button(rec, admin_show_status)
		html = ""
		html << content_tag(:p) do 
			concat content_tag(:button, "approve", {:class => "btn btn-success approve-recipe", :type => "button", :'data-rec-id' => rec.id})
			concat content_tag(:button, "reject", {:class => "btn btn-danger reject-recipe", :type => "button", :'data-rec-id' => rec.id})
		end
		html.html_safe if (user_signed_in? && current_user.is?(:admin) && admin_show_status)



		# <div class="inline"> 
		# 	<button class="btn btn-mini btn-success approve-recipe" type="button" data-rec-id='<%="#{rec.id}"%>'>approve</button>
		# 	<button class="btn btn-mini btn-danger reject-recipe" type="button" data-rec-id='<%="#{rec.id}"%>'>reject</button>
		# </div>
	end

	#gets content down and image on top 
	 

	def print_user_profile_navbar_links
		# @@TODO use contet nested content tage for theis
 		html =""
 		html = '<li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="fa fa-user"></i> '+"#{current_user.name.capitalize }" +'<b class="caret"></b></a><ul class="dropdown-menu">' + (link_to "Sign out", destroy_user_session_path, :method => :delete) + '</ul></li>' if user_signed_in?
		html.html_safe 
	end

	def print_user_recipes_navbar_links
		html = ""
		part2 = ""
		part1 = '<li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">My Recipes<b class="caret"></b></a>'
		part2 <<	content_tag(:ul, :class => "dropdown-menu") do
			concat content_tag(:li, link_to("My Pending Recipe", my_pending_recipes_path))
			concat content_tag(:li, link_to("My Most Rated Recipes", my_most_rated_recipes_path))
			concat content_tag(:li, link_to("My Top Rated Recipes", my_top_rated_recipes_path))
			concat content_tag(:li, link_to("My Approved Recipes", my_approved_recipes_path))
		end
		part3 = "</li>"
		html =(part1+part2+part3) if user_signed_in?
		
		return html.html_safe
	end


	def print_star_rates(aggregate_ratings)
		html =""
		
		html = (0...(aggregate_ratings.to_i)).inject("") {|html, item| html+='<i class="fa fa-star fill-star fa-1x"></i>'}
		html += (0...(5 - aggregate_ratings.to_i)).inject("") {|html, item| html+='<i class="fa fa-star-o muted fa-1x"></i>'}

		html.html_safe
	end


	def print_meal_class(meal_class, page)
		class_name = "info" if meal_class == 'jain'
		class_name = "success" if meal_class == 'veg'
		class_name = "important" if meal_class == 'non-veg'
		html = ""
		html = '<span type="button" class="list-meal-class label label-' + class_name + ' inline" disabled="disabled">'+ meal_class +'</span>' if page == 'list'
		html = '<button type="button" class="btn btn-large btn-'+class_name+' disabled pull-right" disabled="disabled">'+meal_class+'</button>' if page == 'detail'
	
		html.html_safe
	end

	def print_if_notice(notice)
		html = ""
		html = content_tag(:div,  :class => "alert alert-success text-center") do 
			notice
		end if notice

		html.html_safe

		# <%  if notice %>
		# 	<div class="alert alert-success text-center"> 
		# 		<%= notice %>	
		# 	</div>
		# <% end %>
	end
end