# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name_en    :string(255)      default(""), not null
#  name_ja    :string(255)      default(""), not null
#  created_at :datetime
#  updated_at :datetime
#
class Category < ApplicationRecord
  validates :name_en, presence: true, length: { maximum: 32 }
  validates :name_ja, presence: true, length: { maximum: 32 }
  has_many :slides, dependent: false

  # 公開中のスライドが 1 枚以上あるカテゴリ。押しても 0 件のカテゴリは、公開画面に出さない
  scope :with_published_slides, -> { where(id: Slide.published.select(:category_id)) }

  def name
    if I18n.locale.to_s == 'ja'
      name_ja
    else
      name_en
    end
  end
end
