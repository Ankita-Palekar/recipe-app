require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
include SessionsHelper	
	def create_user
		user_hash =  { :name => 'zomato', :email => 'zomato@domain.com', :password => 'zomato123', :password_confirmation  => 'zomato123'}
		User.create(user_hash)
	end

	test "log in" do
		user = create_user
		user_copy = User.find_by_email('zomato@domain.com')
		assert_equal(user,user_copy,'user not saved')
		log_in(user_copy)
		assert_equal(user_copy.id, session[:user_id],'user ids do not match')
	end

	test "current user" do		
		test_log_in
		current = current_user
		assert_equal(current.id, session[:user_id])
	end

	test "logged in?" do
		test_current_user
		assert(logged_in?,'user not logged in')
	end

	test "log out" do
		test_log_in
		log_out
		assert_nil(session[:user_id],'user not logged out')
	end
end
