class ImagesController < ApplicationController
  before_action :set_image, only: [ :show, :edit, :update, :destroy ]

  def index
    @images = Image.order(created_at: :desc).all
  end

  def show
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      redirect_to @image, notice: "Image was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @image.update(image_params)
      redirect_to @image, notice: "Image was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @image.destroy
    redirect_to images_path, notice: "Image was successfully deleted."
  end

  private

  def set_image
    @image = Image.includes(variations: :file_attachment).find(params[:id])
  end

  def image_params
    params.require(:image).permit(:title, :description, :file)
  end
end
