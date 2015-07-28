class SessionsController < ApplicationController
  include SessionsHelper

  #POST /login
  def create
    user = User.find_by_email(params[:email].downcase)
  	if user && user.authenticate(params[:password])
  		 log_in user
       redirect_to '/recipes'
  	else
  		flash[:notice] = "Invalid email/password"
      render 'login'
  	end
  end

  def destroy
    log_out
    redirect_to(:action => '/login') 
  end

 
end
