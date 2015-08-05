module SessionsHelper
	# def log_in(user)
	# 	session[:user_id]  = user.id
	# end

	# def current_user
	# 	@current_user ||= current_user
	# end

	# def logged_in?
	# 	user_signed_in?
	# 	# puts "===================="
	# 	# !current_user.nil?
	# end

	def log_out
    session[:user_id] = nil
    session.delete(:user_id)
  end

  def is_admin?
  	current_user.is_admin?
  end
end
