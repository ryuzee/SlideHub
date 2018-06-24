# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name_en    :string(255)      default(""), not null
#  name_ja    :string(255)      default(""), not null
#

require 'rails_helper'

describe 'Category' do
  let(:category) { build(:default_category) }

  describe 'invalid category names' do
    it 'can not be accepted' do
      invalid_categorynames = [
        'a' * (32 + 1),
        ' ' * (32 + 1),
        ' ' * 32,
      ]
      expect(category).not_to allow_value(*invalid_categorynames).for(:name_en)
      expect(category).not_to allow_value(*invalid_categorynames).for(:name_ja)
    end
  end

  describe 'appropriate name' do
    it 'can be returned' do
      category = create(:default_category)
      expect(category.name).to eq('Category1')
      I18n.locale = :ja
      expect(category.name).to eq('Category1_ja')
    end
  end
end
