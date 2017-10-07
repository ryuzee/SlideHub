require 'rails_helper'

RSpec.describe SlidePageCountController, type: :controller do
  let(:slide) { create(:slide) }

  describe 'GET #show' do
    it 'succeeds to retrieve json' do
      allow_any_instance_of(Slide).to receive(:page_list).and_return(['a'])
      get :show, params: { id: slide.id }
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['page_count']).to eq(1)
    end

    it 'returns 0' do
      allow_any_instance_of(Slide).to receive(:page_list).and_return(['a'])
      get :show, params: { id: 65535 }
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['page_count']).to eq(0)
    end

    it 'returns 0 because of a failure of retrieving json' do
      allow_any_instance_of(Slide).to receive(:page_list).and_return(false)
      get :show, params: { id: slide.id }
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['page_count']).to eq(0)
    end
  end
end
