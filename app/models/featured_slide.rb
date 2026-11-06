# == Schema Information
#
# Table name: featured_slides
#
#  id         :integer          not null, primary key
#  slide_id   :integer          not null
#  position   :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FeaturedSlide < ApplicationRecord
  # トップページに表示する件数（SlideIndex#featured_slides）
  TOP_PAGE_LIMIT = 4

  belongs_to :slide
  validates :slide_id, uniqueness: true
  validate :exsitence_of_slide_id

  # 新しく追加したものは先頭に置く（すぐにトップページに出るように）
  before_create { self.position = (self.class.minimum(:position) || 1) - 1 }

  scope :ordered, -> { order(:position, :id) }

  # トップページの注目のスライドは 3 分間キャッシュしている（slides/index の cache 'featured_slides'）。
  # 追加・削除・並べ替えをすぐに反映させるため、キャッシュを消す
  TOP_PAGE_CACHE_KEY = 'views/featured_slides'.freeze

  after_commit { self.class.expire_top_page_cache }

  def self.expire_top_page_cache
    Rails.cache.delete(TOP_PAGE_CACHE_KEY)
  end

  # 指定した ID の順に並べ直す。指定されなかったものは後ろに回す
  def self.reorder_by_ids(ids)
    ids = ids.map(&:to_i)
    transaction do
      ordered_ids = ids + (ordered.pluck(:id) - ids)
      ordered_ids.each.with_index(1) do |id, position|
        where(id: id).update_all(position: position)
      end
    end
    expire_top_page_cache
  end

  private

    def exsitence_of_slide_id
      errors.add(:slide_id, :inclusion) unless Slide.published.exists?(id: slide_id)
    end
end
