# == Schema Information
#
# Table name: custom_files
#
#  id          :bigint(8)        not null, primary key
#  path        :string(255)      not null
#  description :string(255)
#

class CustomFile < ApplicationRecord
  validates :path, presence: true
  validates :path, length: { maximum: 255 }
  validates :description, length: { maximum: 255 }

  def self.custom_files_directory
    tenant = Tenant.identifier
    if tenant == ''
      'custom-files'
    else
      "custom-files/#{tenant}"
    end
  end
end
