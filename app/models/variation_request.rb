class VariationRequest < ApplicationRecord
  belongs_to :variation, optional: true
  has_many :variation_request_images, dependent: :destroy
  has_many :images, through: :variation_request_images

  validates :prompt, length: { maximum: 1000 }, allow_blank: true
  has_one_attached :mask, dependent: :destroy
  broadcasts_refreshes
  
  
  def attach_mask_data
    return unless mask_data.present?

    io = StringIO.new(Base64.decode64(inverted_mask))
    mask.attach(io: io, filename: "mask.png", content_type: "image/png")
  end

  def inverted_mask
    return nil unless mask_data.present?

    image_date = Base64.decode64(mask_data)

    image = Vips::Image.new_from_buffer(image_date, "")

    inverted = image.invert

    inverted_data = inverted.write_to_buffer(".png")

    Base64.encode64(inverted_data)
  end

  private

  # Store mask data as base64 encoded PNG image
  def mask_image_data
    mask_data
  end
  
  def mask_image_data=(data)
    self.mask_data = data
  end
end
