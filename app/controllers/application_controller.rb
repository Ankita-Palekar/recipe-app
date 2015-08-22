class ApplicationController < ActionController::Base
  # protect_from_forgery
  # @@TODO remember to add message when trying out on actions not authorised to him 
  include SessionsHelper
  
  rescue_from CanCan::AccessDenied do | exception |
    redirect_to root_url, notice: exception.message
  end

  before_filter :allow_cross_domain_access
  def allow_cross_domain_access
    request.headers["Access-Control-Allow-Origin"] = "*"
    request.headers["Access-Control-Allow-Methods"] = "*"
  end

  
  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Expose-Headers'] = 'ETag'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match'
    headers['Access-Control-Max-Age'] = '86400'
  end




end
