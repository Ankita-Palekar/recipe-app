require 'test_helper'
class UserTest < ActiveSupport::TestCase
  include SessionsHelper  
	 

	#needs to load data from fixture
  test "send email notification recipe approved" do
    user = User.find_by_id(1)
    assert_not_nil(user, 'user is nil') 
    user.send_email_notification_recipe_approved
    last_email = ActionMailer::Base.deliveries.last
    assert_equal(user.email, last_email.to.first)
  end

  test "authenticate" do
  	user = create_user_helper
  	user_copy = User.find_by_email('zomato@domain.com')
  	assert_equal(user, user_copy, 'user not saved')
  	assert(BCrypt::Password.new(user_copy.password_digest) == 'zomato123', 'password do not match')
  end 

  test "authentication fail" do
  	user = create_user_helper
  	user_copy = User.find_by_email('zomato@domain.com')
  	assert_equal(user, user_copy, 'user not saved')
  	Rails::logger.debug BCrypt::Password.new(user_copy.password_digest) == 'zomato123xxxxxxxxxxxxxx'
  	assert(!(BCrypt::Password.new(user_copy.password_digest) == 'zomato123xxxxxxxxxxxxxx'), 'error')
  end 
end
