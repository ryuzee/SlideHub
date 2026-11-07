# == Schema Information
#
# Table name: pages
#
#  id         :bigint           not null, primary key
#  content    :text(4294967295)
#  path       :string(30)       not null
#  title      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Page < ApplicationRecord
  validates :path, presence: true
  validates :path, uniqueness: true, length: { minimum: 3, maximum: 32 }
  VALID_PATH_REGEX = /\A[0-9A-Za-z][0-9A-Za-z\-_]{1,30}[a-zA-Z0-9]\z/
  validates :path, format: { with: VALID_PATH_REGEX }
  validates :title, presence: true
  validates :title, length: { minimum: 2, maximum: 255 }
  validates :content, presence: true
  validates :content, length: { maximum: 4_294_967_295 }

  # 管理画面の一覧で並べ替えに使う項目
  def self.ransackable_attributes(_auth_object = nil)
    %w[id path title created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
