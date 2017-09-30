# == Schema Information
#
# Table name: configs
#
#  name     :string(32)       not null, primary key
#  value    :string(255)      default(""), not null
#  created  :datetime         not null
#  modified :datetime
#

class Config < ApplicationRecord
end
