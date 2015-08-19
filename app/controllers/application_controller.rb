class ApplicationController < ActionController::Base
  # protect_from_forgery
  # @@TODO remember to add message when trying out on actions not authorised to him 
  include SessionsHelper
  before_filter :allow_cross_domain_access
  
  rescue_from CanCan::AccessDenied do | exception |
    redirect_to root_url, notice: exception.message
  end

  def allow_cross_domain_access
    response.headers["Access-Control-Allow-Origin"] = "http://1925030143.rsc.cdn77.org"
    response.headers["Access-Control-Allow-Methods"] = "GET"
  end

end
