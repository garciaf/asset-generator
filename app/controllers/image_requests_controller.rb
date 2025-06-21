class ImageRequestsController < ApplicationController
  def index
    @image_requests = ImageRequest.includes(:style).all
  end

  def show
    @image_request = ImageRequest.find(params[:id])
  end

  def new
    @image_request = ImageRequest.new
    @styles = Style.all
  end

  def create
    @image_request = ImageRequest.new(image_request_params)

    if @image_request.save
      # Trigger the image generation job
      GenerateImageJob.perform_later(@image_request)
      redirect_to @image_request, notice: "Image request was successfully created. Image generation has started."
    else
      @styles = Style.all
      render :new
    end
  end

  def generate
    @image_request = ImageRequest.find(params[:id])
    GenerateImageJob.perform_later(@image_request)
    redirect_to @image_request, notice: "Image generation has been triggered."
  rescue ActiveRecord::RecordNotFound
    redirect_to image_requests_path, alert: "Image request not found."
  end

  private

  def image_request_params
    params.require(:image_request).permit(:prompt, :style_id)
  end
end
