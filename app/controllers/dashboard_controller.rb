class DashboardController < ApplicationController
  def index
    @styles_count = Style.count
    @images_count = Image.count
    @variations_count = Variation.count
    @recent_images = Image.order(created_at: :desc).limit(6)
  end
end
