class CustomFile < ApplicationRecord
  validates :path, presence: true
  validates :path, length: { maximum: 255 }
  validates :description, length: { maximum: 255 }
end
