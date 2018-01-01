class Page < ApplicationRecord
  validates :path, presence: true
  validates :path, uniqueness: true, length: { minimum: 3, maximum: 32 }
  VALID_PATH_REGEX = /\A[0-9A-Za-z][0-9A-Za-z\-_]{1,30}[a-zA-Z0-9]\z/
  validates :path, format: { with: VALID_PATH_REGEX }
  validates :title, presence: true
  validates :title, length: { minimum: 2, maximum: 255 }
  validates :content, presence: true
  validates :content, length: { maximum: 4_294_967_295 }
end
