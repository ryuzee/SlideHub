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
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#

class Slide < ApplicationRecord
  include WebResource
  belongs_to :user
  delegate :username, to: :user, prefix: true
  delegate :display_name, to: :user, prefix: true
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

  scope :published, -> { where('convert_status = 100') }
  scope :failed, -> { where('convert_status != 100') }
  scope :latest, -> { order('created_at desc') }
  scope :popular, -> { order('total_view desc') }
  scope :category, ->(category_id) { where('category_id = ?', category_id) }
  scope :owner, ->(user_id) { where('user_id = ?', user_id) }

  def self.latest_slides(limit = 10)
    self.published.latest.
      includes(:user).
      limit(limit)
  end

  def self.popular_slides(limit = 10)
    self.published.popular.
      includes(:user).
      limit(limit)
  end

  # :reek:UncommunicativeVariableName { enabled: false }
  def self.featured_slides(limit = 10)
    ids = FeaturedSlide.order(created_at: 'desc').pluck(:slide_id)
    slides = self.published.
             includes(:user).
             where(id: ids).
             limit(limit)
    ids.collect { |id| slides.detect { |x| x.id == id.to_i } }
  end

  # :reek:UnusedParameters { enabled: false }
  def self.ransackable_attributes(auth_object = nil)
    (column_names + ['tag_search']) + _ransackers.keys
  end

  def self.key_exist?(key)
    Slide.where('slides.object_key = ?', key).count > 0
  end

  def self.related_slides(category_id, slide_id, limit = 10)
    Slide.published.latest.
      where('category_id = ?', category_id).
      where('id != ?', slide_id).
      limit(limit).
      includes(:user)
  end

  def send_convert_request
    CloudConfig::SERVICE.send_message({ id: id, object_key: object_key }.to_json)
  end

  def delete_uploaded_files
    CloudConfig::SERVICE.delete_slide(object_key)
    CloudConfig::SERVICE.delete_generated_files(object_key)
  end

  def thumbnail_url
    "#{CloudConfig::SERVICE.resource_endpoint}/#{object_key}/thumbnail.jpg"
  end

  def transcript_url
    "#{CloudConfig::SERVICE.resource_endpoint}/#{object_key}/transcript.txt"
  end

  def page_list_url
    "#{CloudConfig::SERVICE.resource_endpoint}/#{object_key}/list.json"
  end

  # :reek:UncommunicativeVariableName { enabled: false }
  def page_list
    len = num_of_pages.abs.to_s.length
    result = []
    (1..num_of_pages).each do |i|
      n = i.to_s.rjust(len, '0')
      result.push("#{object_key}/slide-#{n}.jpg")
    end
    result
  end

  def transcript
    @transcript ||= get_php_serialized_data(self.transcript_url)
  end

  def transcript_exist?
    result = false
    if transcript.instance_of?(Array)
      transcript.each do |tran|
        unless tran.empty?
          result = true
          break
        end
      end
    end
    result
  end
end
