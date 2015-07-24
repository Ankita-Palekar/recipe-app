require 'test_helper'
class UserTest < ActiveSupport::TestCase

	#needs to load data from fixture
  test "send email notification recipe approved" do
    user = User.find_by_id(1)
    assert_not_nil(user, 'user is nil') 
    user.send_email_notification_recipe_approved
    last_email = ActionMailer::Base.deliveries.last
    assert_equal(user.email, last_email.to.first)
  end
end
