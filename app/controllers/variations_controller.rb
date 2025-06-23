class VariationsController < ApplicationController
  before_action :set_variation, only: [ :show, :edit, :update, :destroy ]

  def index
    @variations = Variation.includes(:image).order(created_at: :desc).all
  end

  def show
  end

  def new
    @variation = Variation.new
    @variation.image_id = params[:image_id] if params[:image_id].present?
    @images = Image.order(:title, :id).all
  end

  def create
    @variation = Variation.new(variation_params)

    if @variation.save
      redirect_to @variation, notice: "Variation was successfully created."
    else
      @images = Image.order(:title, :id).all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @images = Image.order(:title, :id).all
  end

  def update
    if @variation.update(variation_params)
      redirect_to @variation, notice: "Variation was successfully updated."
    else
      @images = Image.order(:title, :id).all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @variation.destroy
    redirect_to variations_path, notice: "Variation was successfully deleted."
  end

  private

  def set_variation
    @variation = Variation.includes(:image, :variation_request).find(params[:id])
  end

  def variation_params
    params.require(:variation).permit(:image_id, :file)
  end
end
