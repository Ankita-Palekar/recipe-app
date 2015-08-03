require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
 	include SessionsHelper
  include ReusableFunctionsTests
  
  test "should get new" do
    get :login
    assert_response :success
  end

  test "should create session if logged in" do
  	# set session to null
  	# session[:user_id] = nil
   	user = create_user_helper
  	user_copy = User.find_by_email('zomato@domain.com')
  	assert_equal(user, user_copy, 'user not saved')
  	post(:create, {:email => 'zomato@domain.com', :password => 'zomato123'})
    Rails::logger.debug flash
  	assert_response(:redirect, message = "no redirect")
  	assert_redirected_to('/' , message='not redirecting to recipes') #should be home here
  end

  test "should create session if not logged in" do
  	user = create_user_helper
  	user_copy = User.find_by_email('zomato@domain.com')
  	assert_equal(user, user_copy, 'user not saved')
    post :create, {:email => 'zomato@domain.com', :password => 'zomato1234sdsds'}	 
  	assert_equal('Invalid email/password', flash[:notice], 'flash message not matching')
  	assert_template(expected = 'login', message='not rendering login page')
  end

end
