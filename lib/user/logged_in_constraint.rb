class LoggedInConstraint
	def logged_in?(request)
		@current_user ||= User.find_by_id(session[:user_id])
		!@current_user.nil?
	end
end