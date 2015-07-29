class SessionsController < ApplicationController
  include SessionsHelper

  #POST /login
  def create
    # user = User.find_by_email(params[:email].downcase)
  	# if user && user.authenticate(params[:password])
  	if user = User.authenticate(:email => params[:email] , :password => params[:password])	
      log_in user
      flash[:notice] = "Sucessfully signed in"
      redirect_to(:controller => "recipes", :action => "index") 
  	else
  		flash[:notice] = "Invalid email/password"
      render 'login'
  	end
  end

  def destroy
    log_out
    redirect_to '/login'
  end
end
