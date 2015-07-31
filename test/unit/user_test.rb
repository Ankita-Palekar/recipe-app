require 'test_helper'
class UserTest < ActiveSupport::TestCase
  include SessionsHelper  
  include ReusableFunctionsTests
	 

	#needs to load data from fixture
  test "send email notification for recipes approval" do
    user = User.find(1)
    assert_not_nil(user, 'user is nil') 
    user.send_email_notification_for_recipes(:function_name => 'recipe_approval_email')
    Rails::logger.debug  "=================="
    last_email = ActionMailer::Base.deliveries.last
    Rails::logger.debug last_email
    assert_not_nil(last_email, 'email buffer blank')
    # assert_equal(user.email, last_email.to.first)
  end


  test "send email notification for recipes rejected" do
    user = User.find(1)
    assert_not_nil(user, 'user is nil') 
    user.send_email_notification_for_recipes(:function_name => 'recipe_rejected_email')
    last_email = ActionMailer::Base.deliveries.last
    assert_not_nil(last_email, 'email buffer blank')

    # assert_equal(user.email, last_email.to.first)
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
