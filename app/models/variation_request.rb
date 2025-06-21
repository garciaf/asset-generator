class VariationRequest < ApplicationRecord
  belongs_to :variation, optional: true
  has_many :variation_request_images, dependent: :destroy
  has_many :images, through: :variation_request_images

  validates :prompt, length: { maximum: 1000 }, allow_blank: true
  broadcasts_refreshes
end
