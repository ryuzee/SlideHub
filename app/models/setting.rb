# == Schema Information
#
# Table name: settings
#
#  id         :integer          not null, primary key
#  var        :string(255)      not null
#  value      :text(4294967295)
#  created_at :datetime
#  updated_at :datetime
#

class Setting < ApplicationRecord
  serialize :value
end
