class ApplicationController < ActionController::Base
  # protect_from_forgery
  include SessionsHelper
  # create is of sessions_controller
  # before_filter :confirm_logged_in, :except => [:login, :logout, :create, :signup, :new]
  # before_filter :confirm_is_admin, :only =>[:admin_pending_recipes]
 
  protected

  # def confirm_logged_in
  # 	unless logged_in?
  # 		flash[:notice] = 'login before carying out any action'
  #     redirect_to '/login'
  # 		return false
  # 	else
  # 		return true
  # 	end
  # end

  # def confirm_is_admin
  #   unless is_admin?
  #     redirect_to '/caution'
  #     return false
  #   else
  #     return true
  #   end
  # end
end
