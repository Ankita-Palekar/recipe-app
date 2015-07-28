require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get new" do
    get :login
    assert_response :success
  end

  test "should create session" do
  	
  end

end
