# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(32)       not null
#  display_name           :string(128)      not null
#  password               :string(255)      default(""), not null
#  admin                  :boolean          default(FALSE), not null
#  disabled               :boolean          default(FALSE)
#  created_at             :datetime         not null
#  modified_at            :datetime
#  biography              :text(65535)
#  slides_count           :integer          default(0)
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  avatar_file_name       :string(255)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  username               :string(255)      not null
#

require 'spec_helper'
require 'rails_helper'

describe 'User' do
  let(:user) { build(:general_user) }

  describe 'valid usernames' do
    valid_usernames = %w(
      ryuzee
      ryuzee-1234
      RYUZEE
      ryu
    )
    it { expect(user).to allow_value(*valid_usernames).for(:username) }
  end

  describe 'invalid usernames' do
    invalid_usernames = [
      'ryuzee@example.com',
      'search',
      '-ryuzee',
      'ryu zee',
      'ry',
      'ryuzee789012345678901234567890123',
    ]
    it { expect(user).not_to allow_value(*invalid_usernames).for(:username) }
  end

  describe 'username_to_id' do
    it 'returns user_id' do
      general_user = FactoryGirl.create(:general_user)
      id = User.username_to_id(general_user.username)
      expect(id).to eq(998)
    end
  end
end
