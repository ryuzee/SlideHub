# == Schema Information
#
# Table name: slides
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  name           :string(255)      not null
#  description    :text(65535)      not null
#  downloadable   :boolean          default(FALSE), not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  modified_at    :datetime
#  key            :string(255)      default("")
#  extension      :string(10)       default(""), not null
#  convert_status :integer          default(0)
#  total_view     :integer          default(0), not null
#  page_view      :integer          default(0)
#  download_count :integer          default(0), not null
#  embedded_view  :integer          default(0), not null
#  num_of_pages   :integer          default(0)
#  comments_count :integer          default(0), not null
#

require 'rails_helper'

describe 'Slides' do
  describe 'GET /slides' do
    it 'works!' do
      get '/slides'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/1' do
    it 'works!' do
      create_list(:slide, 2)
      allow_any_instance_of(Slide).to receive(:page_list).and_return(['/aaa/1.jpg', '/aaa/2.jpg'])
      allow_any_instance_of(Slide).to receive(:transcript).and_return([])
      get '/slides/1'
      expect(response.status).to eq(200)
    end
  end
end
