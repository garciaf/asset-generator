class Image < ApplicationRecord
  has_many :image_requests, dependent: :destroy
  has_many :variations, dependent: :destroy
  has_many :variation_request_images, dependent: :destroy
  has_many :variation_requests, through: :variation_request_images

  has_one_attached :file

  validates :title, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }
end
