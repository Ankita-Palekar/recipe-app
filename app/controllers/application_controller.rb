class ApplicationController < ActionController::Base
  # protect_from_forgery
  include SessionsHelper
	# before_filter :configure_sign_up_params, only: [:create]

 #  def configure_sign_up_params
 #    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email) }
 #  end

  # before_filter :configure_permitted_parameters, if: :devise_controller?
  # protected

  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:name) }
  # end

end
