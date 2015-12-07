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
#  modified_at    :datetime
#  key            :string(255)      default('')
#  extension      :string(10)       default(''), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#

class Slide < ActiveRecord::Base
  include WebResource
  belongs_to :user
  counter_culture :user
  belongs_to :category
  has_many :comments, as: :commentable, dependent: :delete_all
  acts_as_commentable :private
  acts_as_taggable
  validates :user_id, presence: true
  validates :name, presence: true
  validates :name, length: { maximum: 255 }
  validates :description, presence: true
  validates :description, length: { maximum: 2048 }
  validates :key, presence: true
  validates :key, uniqueness: true
  validates :category_id, presence: true

  scope :published, -> { where('convert_status = 100') }
  scope :failed, -> { where('convert_status != 100') }
  scope :latest, -> { order('created_at desc') }
  scope :popular, -> { order('total_view desc') }
  scope :category, -> (category_id) { where('category_id = ?', category_id) }
  scope :owner, -> (user_id) { where('user_id = ?', user_id) }

  def self.ransackable_attributes(auth_object = nil)
    (column_names + ['tag_search']) + _ransackers.keys
  end

  def thumbnail_url
    "#{Myapp::Application.config.oss_resource_endpoint}/#{key}/thumbnail.jpg"
  end

  def transcript_url
    "#{Myapp::Application.config.oss_resource_endpoint}/#{key}/transcript.txt"
  end

  def page_list_url
    "#{Myapp::Application.config.oss_resource_endpoint}/#{key}/list.json"
  end

  def page_list
    url = self.page_list_url
    return get_json(url)
  end

  def transcript
    begin
      response =  Net::HTTP.get_response(URI.parse(self.transcript_url))
      case response
      when Net::HTTPSuccess
        response = response.body.dup.force_encoding('utf-8')
        require 'php_serialization/unserializer'
        return PhpSerialization::Unserializer.new.run(response)
      else
        puts response.value
        return []
      end
    rescue => e
      puts [e.class, e].join(' : ')
    end
  end
end
