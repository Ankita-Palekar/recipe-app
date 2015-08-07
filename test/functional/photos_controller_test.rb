require 'test_helper'

class PhotosControllerTest < ActionController::TestCase
	include ReusableFunctionsTests
  setup do
    @user = users(:one)
  end

  test "should create photo" do
		image = fixture_file_upload('cover.png', 'image/png')
		assert_difference('Photo.count') do
		 	post :create, file: image
		end
		assert_response :success
		assert_equal("image uploaded successfully", flash[:notice])
	end

	test "should delete image" do 
		@photo = upload_image
	 	assert_difference('Upload.count', -1) do
	 	  delete :destroy, id: @photo
	 	end	
	 	assert_equal("File deleted from server", flash[:notice])
	end
end