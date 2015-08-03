require 'test_helper'
class UserTest < ActiveSupport::TestCase
  include SessionsHelper  
  include ReusableFunctionsTests
	
  test "admin_notify_email" do
    user = User.find(1)
    email = user.admin_notify_email(function_name: 'recipe_created_email')
    assert !ActionMailer::Base.deliveries.empty?
    last_email = ActionMailer::Base.deliveries.last
    assert_not_nil(last_email, 'email buffer blank')
    assert_equal(email.to.first, user.email, 'emails do not match')
  end

  test "user_notify_email_approval" do
    user = User.find(1)
    email = user.user_notify_email(function_name: 'recipe_approval_email')
    assert !ActionMailer::Base.deliveries.empty?
    last_email = ActionMailer::Base.deliveries.last
    assert_not_nil(last_email, 'email buffer blank')
    assert_equal(email.to.first, user.email, 'emails do not match')
  end

  test "user_notify_email_reject" do
    user = User.find(1)
    email = user.user_notify_email(function_name: 'recipe_approval_email')
    assert !ActionMailer::Base.deliveries.empty?
    last_email = ActionMailer::Base.deliveries.last
    assert_not_nil(last_email, 'email buffer blank')
    assert_equal(email.to.first, user.email, 'emails do not match')
  end


	# #needs to load data from fixture
 #  test "send email notification for recipes approval" do
 #    user = User.find(1)
 #    assert_not_nil(user, 'user is nil') 
 #    user.send_email_notification_for_recipes(:function_name => 'recipe_approval_email')
 #    last_email = ActionMailer::Base.deliveries.last
 #    assert_not_nil(last_email, 'email buffer blank')
 #    # assert_equal(user.email, last_email.to.first)
 #  end
  # test "send email notification for recipes rejected" do
  #   user = User.find(1)
  #   assert_not_nil(user, 'user is nil') 
  #   user.send_email_notification_for_recipes(:function_name => 'recipe_rejected_email')
  #   last_email = ActionMailer::Base.deliveries.last
  #   assert_not_nil(last_email, 'email buffer blank')
  # end


 

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


  test "get_admins" do
    admin_list = User.get_admins
    admin_list.each {|admin| assert(admin.is_admin?, 'not admin')}
  end


  test "create_user" do
    user_data = {:name => 'ankita',:email => 'ankita@vacationlabs.com', :password => 'ankita123', :password_confirmation => 'ankita123'}
    user = User.new(user_data)
    user = user.create_user
    user_copy = User.find(user.id)
    assert(user_copy.present?, 'user not created')
  end


end
