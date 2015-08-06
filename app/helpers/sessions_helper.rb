module SessionsHelper
	def logged_in?
		user_signed_in?
	end

	def log_out
    session[:user_id] = nil
    session.delete(:user_id)
  end

  def is_admin?
  	current_user.is_admin if logged_in?
  end
end
