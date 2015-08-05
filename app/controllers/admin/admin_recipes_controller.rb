class Admin::AdminRecipesController < ApplicationController
	
	before_filter :confirm_is_admin
	
	def approve_recipe
	  @current_user = current_user
	  @recipe = Recipe.find(params[:recipe][:id]) 
	  respond_to do |format|
	    begin
	      notice = {}
	      notice[:message] = @recipe.approve_recipe(current_user: @current_user) ? 'successfully approved' : 'could not be approved'
	      format.html {redirect_to @recipe , notice: notice}
	      format.json { render json: @recipe , notice: notice} 
	    end if params[:recipe][:approved] == "true"
	  end
	end

	def reject_recipe
	  @current_user = current_user
	  @recipe = Recipe.find(params[:recipe][:id]) 
	  respond_to do |format|
	    begin
	      notice = {}
	      notice[:message] = @recipe.reject_recipe(current_user: @current_user) ? 'successfully rejected' : 'could not be rejected'
	      format.html {redirect_to @recipe , notice: notice}
	      format.json { render json: @recipe , notice: notice}  
	    end if(params[:recipe][:rejected] == "true")
	  end
	end
	protected
	def confirm_is_admin
	  unless is_admin?
	    redirect_to '/caution'
	    return false
	  else
	    return true
	  end
	end
end
 
