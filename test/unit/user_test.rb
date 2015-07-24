require 'test_helper'
class UserTest < ActiveSupport::TestCase
  test "check email sent" do
    user = User.first
    assert(!user.valid?, 'user is invalid') 
    
    user.send_email_notification_recipe_approved
    last_email = ActionMailer::Base.deliveries.last
    assert_equal(user.email, last_email.to.first)
  end
end
