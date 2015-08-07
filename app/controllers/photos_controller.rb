class PhotosController < ApplicationController
	def new
	  @photo = Photo.new
	end

  def create
  	@photo = Photo.new
    @photo.avatar = params[:file]
    if @photo.save
  	  render json: { object: @photo }, :status => 200
      # flash[:notice] = "image uploaded successfully"
  	else
  	  render json: { error: @photo.errors.full_messages.join(',')}, :status => 400
  	end  		
  end

  def destroy
    @photo = Photo.find(params[:id])
    if @photo.destroy    
      render json: { message: 'File deleted from server' }
    else
      render json: { message: @photo.errors.full_messages.join(',') }
    end
  end

  private
  def photo_params
  	params.require(:photo).permit(:image)
  end
end