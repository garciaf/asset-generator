class Style < ApplicationRecord
  validates :title, presence: true, length: { minimum: 1, maximum: 100 }
  validates :prompt, presence: true, length: { minimum: 10, maximum: 2000 }
end
