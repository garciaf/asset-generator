class VariationRequestImage < ApplicationRecord
  belongs_to :variation_request
  belongs_to :image

  validates :variation_request, presence: true
  validates :image, presence: true
  validates :image_id, uniqueness: { scope: :variation_request_id }
end
