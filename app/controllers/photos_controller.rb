class PhotosController < ApplicationController
	def new
	  @photo = Photo.new
	end

  def create
  	puts "======================="
  	puts params.inspect
  	# params[:avatar] = params[:file]
  	

  	@photo = Photo.new
  	@photo.update_attributes(:avatar => params[:file])

  	if @photo.save
  	  render json: { message: "success" }, :status => 200
  	else
  	  #  you need to send an error header, otherwise Dropzone
          #  will not interpret the response as an error:
  	  render json: { error: @photo.errors.full_messages.join(',')}, :status => 400
  	end  		
  end

  private
  def photo_params
  	params.require(:photo).permit(:image)
  end
end