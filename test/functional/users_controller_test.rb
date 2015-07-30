require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :signup
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference 'User.count' do
      post :create, { :name => 'zomato', :email => 'zomato@domain.com', :password => 'zomato123', :password_confirmation  => 'zomato123'}
    end
    assert_redirected_to('/login', messgae = 'not redirected to login')
    assert_equal('Sucessfully signed up! you can login now', flash[:notice], messgae = 'flash message not equal')
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: {  }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
