require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
 	def create_user
 		user_hash =  { :name => 'zomato', :email => 'zomato@domain.com', :password => 'zomato123', :password_confirmation  => 'zomato123'}
 		User.create(user_hash)
 	end

  test "should get new" do
    get :login
    assert_response :success
  end

  test "should create session if logged in" do
  	# set session to null
  	# session[:user_id] = nil
   	user = create_user
  	user_copy = User.find_by_email('zomato@domain.com')
  	assert_equal(user, user_copy, 'user not saved')
  	post(:login, {:email => 'zomato@domain.com', :password => 'zomato123'})
  	 
  	assert_response :redirect
    Rails::logger.debug @response.inspect	
    Rails::logger.debug flash.inspect	
  	assert_redirected_to(redirect_to(:controller => 'recipes', :action => 'index'), message='not redirecting to recipes') #should be home here
  end

  test "should create session if not logged in" do
  	user = create_user
  	user_copy = User.find_by_email('zomato@domain.com')
  	assert_equal(user, user_copy, 'user not saved')
  	post :create, {:email => 'zomato@domain.com', :password => 'zomato123'}	 
    Rails::logger.debug flash.inspect
  	assert_equal('Invalid email/password', flash[:notice], 'flash message not matching')
  	assert_template(expected = 'login', message='not rendering login page')
  end

end
