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
