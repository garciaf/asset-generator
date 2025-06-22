class Style < ApplicationRecord
  validates :title, presence: true, length: { minimum: 1, maximum: 100 }
end
