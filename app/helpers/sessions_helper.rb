module SessionsHelper
	def log_in(user)
		session[:user_id]  = user.id
	end

	def current_user
		@current_user ||= User.find_by_id(session[:user_id])
	end

	def logged_in?
		!current_user.nil?
	end

	def log_out
    session[:user_id] = nil
    session.delete(:user_id)
  end

  def is_admin?
  	puts "==========================="
  	puts current_user
  	puts current_user.is_admin?
  	current_user.is_admin?
  end
end
