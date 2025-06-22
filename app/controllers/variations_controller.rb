class VariationsController < ApplicationController
  def index
    @variations = Variation.includes(:image).order(created_at: :desc).all
  end

  def show
    @variation = Variation.includes(:image, :variation_request).find(params[:id])
  end

  def destroy
    @variation = Variation.find(params[:id])
    @variation.destroy
    redirect_to variations_path, notice: "Variation was successfully deleted."
  end
end
