# == Schema Information
#
# Table name: custom_contents
#
#  name     :string(32)       not null, primary key
#  value    :text(65535)      not null
#  created  :datetime         not null
#  modified :datetime
#

require 'test_helper'

class CustomContentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
