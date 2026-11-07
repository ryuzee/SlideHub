# == Schema Information
#
# Table name: settings
#
#  id         :integer          not null, primary key
#  value      :text(4294967295)
#  var        :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#
class Setting < ApplicationRecord
  serialize :value, coder: YAML
end
