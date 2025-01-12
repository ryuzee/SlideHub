require 'net/http'
require 'uri'
require 'json'
require 'securerandom'
# == Schema Information
#
# Table name: slides
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  name           :string(255)      not null
#  description    :text(65535)      not null
#  downloadable   :boolean          default(FALSE), not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime
#  object_key     :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default("unconverted")
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#  private        :boolean          default(FALSE), not null
#

class Slide < ApplicationRecord
  include WebResource
  belongs_to :user
  delegate :username, to: :user, prefix: true
  delegate :display_name, to: :user, prefix: true
  delegate :twitter_account, to: :user, prefix: true
  counter_culture :user
  belongs_to :category
  delegate :name, to: :category, prefix: true
  has_many :comments, dependent: :delete_all
  acts_as_taggable
  validates :user_id, presence: true
  validates :name, presence: true
  validates :name, length: { maximum: 255 }
  validates :description, presence: true
  validates :description, length: { maximum: 2048 }
  validates :object_key, presence: true
  validates :object_key, uniqueness: true
  validates :category_id, presence: true
  # validates :category_id, :presence => true, :inclusion => { :in => Category.all.map(&:id) }

  enum convert_status: { unconverted: 0, converted: 100, convert_error: -1 }

  scope :published, -> { where('convert_status = ? and private != 1', convert_statuses[:converted]) }
  scope :failed, -> { where('convert_status != ?', convert_statuses[:converted]) }
  scope :latest, -> { order('created_at desc') }
  scope :popular, -> { order('total_view desc') }
  scope :category, ->(category_id) { where('category_id = ?', category_id) }
  scope :owner, ->(user_id) { where('user_id = ?', user_id) }

  def self.ransackable_associations(auth_object = nil)
    %w[base_tags category comments tag_taggings taggings tags user]
  end

  def record_access(access_type)
    increment!(:page_view).increment!(:total_view) if access_type == :page_view
    increment!(:embedded_view).increment!(:total_view) if access_type == :embedded_view
  end

  # :reek:UnusedParameters { enabled: false }
  def self.ransackable_attributes(auth_object = nil)
    (column_names + ['tag_search']) + _ransackers.keys
  end

  def self.key_exist?(key)
    Slide.where('slides.object_key = ?', key).count.positive?
  end

  def self.update_after_convert(object_key, file_type, num_of_pages)
    slide = Slide.find_by(object_key: object_key)
    if slide
      slide.converted!
      slide.extension = ".#{file_type}"
      slide.num_of_pages = num_of_pages
      slide.save
    else
      logger.info('There is no slide in this database...')
      false
    end
  end

  def pages
    @pages ||= SlidePages.new(object_key, num_of_pages)
  end

  def transcript
    @transcript ||= Transcript.new(object_key)
  end

  def thumbnail
    @thumbnail ||= Thumbnail.new(object_key)
  end
end
