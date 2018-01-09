# == Schema Information
#
# Table name: pages
#
#  id         :integer          not null, primary key
#  path       :string(30)       not null
#  title      :string(255)      not null
#  content    :text(4294967295)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe 'Page' do
  let(:page) { build(:default_page) }

  describe 'valid path' do
    it 'can be accepted' do
      valid_path = [
        '123',
        'abc',
        'a12',
        'a-b',
        'a' * 32,
      ]
      expect(page).to allow_value(*valid_path).for(:path)
    end
  end

  describe 'invalid path' do
    it 'can not be accepted' do
      invalid_path = [
        '',
        '_ab',
        '-ab',
        '#12',
        '12',
        'ab',
        ' ' * 3,
        'a' * 33,
      ]
      expect(page).not_to allow_value(*invalid_path).for(:path)
    end
  end

  describe 'valid title' do
    it 'can be accepted' do
      valid_title = [
        '12',
        '-_',
        'a' * 255,
      ]
      expect(page).to allow_value(*valid_title).for(:title)
    end
  end

  describe 'invalid title' do
    it 'can not be accepted' do
      invalid_title = [
        '',
        'a' * 256,
      ]
      expect(page).not_to allow_value(*invalid_title).for(:title)
    end
  end

  describe 'invalid content' do
    it 'can not be accepted' do
      invalid_content = [
        '',
        ' ' * 256,
      ]
      expect(page).not_to allow_value(*invalid_content).for(:content)
    end
  end

  describe 'trying to create a page with same name' do
    it 'will fail' do
      _default_page = FactoryBot.create(:default_page)
      data = { path: 'aaa', title: 'dummy1', content: 'dummy12345' }
      page = Page.new(data)
      expect(page.valid?).to eq(false)
    end
  end
end
