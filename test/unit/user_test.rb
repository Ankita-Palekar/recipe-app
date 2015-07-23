require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "password confirmation" do
    user = users(:user1)
    user.password = "abc"
    assert !user.save

    user.password = "pass"
    user.password_confirmation = "p"
    assert !user.save

    user.password = ""
    user.password_confirmation = "p"
    assert user.save

    user.password = "password1"
    user.password_confirmation = "password1"
    assert user.save
  end

  test "my test" do
  	assert true
	end
end
