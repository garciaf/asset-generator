class ImageRequest < ApplicationRecord
  belongs_to :style
  belongs_to :image, optional: true

  validates :prompt, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :style, presence: true
  broadcasts_refreshes
end
