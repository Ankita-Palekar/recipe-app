class ApplicationController < ActionController::Base
  # protect_from_forgery
  # @@TODO remember to add message when trying out on actions not authorised to him 
  include SessionsHelper
  
  rescue_from CanCan::AccessDenied do | exception |
    redirect_to root_url, notice: exception.message
  end

  before_filter :allow_cross_domain_access
  def allow_cross_domain_access
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "*"
  end



end
