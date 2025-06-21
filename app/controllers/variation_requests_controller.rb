class VariationRequestsController < ApplicationController
  def index
    @variation_requests = VariationRequest.includes(:variation, :images).all
  end

  def show
    @variation_request = VariationRequest.find(params[:id])
  end

  def new
    @variation_request = VariationRequest.new
    @images = Image.joins(:file_attachment).where.not(active_storage_attachments: { id: nil })
  end

  def create
    @variation_request = VariationRequest.new(variation_request_params)

    if @variation_request.save
      # Trigger the variation generation job
      GenerateVariationJob.perform_later(@variation_request)
      redirect_to @variation_request, notice: "Variation request was successfully created. Variation generation has started."
    else
      @images = Image.joins(:file_attachment).where.not(active_storage_attachments: { id: nil })
      render :new
    end
  end

  private

  def variation_request_params
    params.require(:variation_request).permit(:prompt, image_ids: [])
  end
end
