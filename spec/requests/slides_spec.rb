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
#  updated_at     :datetime
#  object_key     :string(255)      default("")
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
    it 'shows the top page with the latest slides' do
      create(:slide, name: 'Sushi Talk')
      get '/slides'
      expect(response.status).to eq(200)
      expect(response.body).to include('Sushi Talk')
    end
  end

  describe 'any page' do
    it 'does not delete sessions while showing a page' do
      expect(ActiveRecord::SessionStore::Session).not_to receive(:where)
      get '/slides'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /slides/1' do
    it 'shows the slide with its first page' do
      slide = create(:slide, name: 'Sushi Talk', num_of_pages: 2)
      get "/slides/#{slide.id}"
      expect(response.status).to eq(200)
      expect(response.body).to include('Sushi Talk')
      expect(response.body).to include("#{slide.object_key}/slide-1.jpg")
    end
  end
end
