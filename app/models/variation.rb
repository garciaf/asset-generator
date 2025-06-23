class Variation < ApplicationRecord
  belongs_to :image
  has_one :variation_request, dependent: :destroy

  has_one_attached :file

  validates :image, presence: true
  validates :file, presence: true, on: :create
end
