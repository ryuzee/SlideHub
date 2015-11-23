# == Schema Information
#
# Table name: configs
#
#  name     :string(32)       not null, primary key
#  value    :string(255)      default(""), not null
#  created  :datetime         not null
#  modified :datetime
#

require 'test_helper'

class ConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
