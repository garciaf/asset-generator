class VariationsController < ApplicationController
  def index
    @variations = Variation.includes(:image).all
  end

  def show
    @variation = Variation.find(params[:id])
  end
end
