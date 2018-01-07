require 'rails_helper'

describe 'Player' do
  describe 'GET /player/1' do
    it 'works!' do
      create(:slide)
      allow_any_instance_of(Slide).to receive(:page_list).and_return(['/aaa/1.jpg'])
      allow_any_instance_of(Slide).to receive(:transcript).and_return([])
      get '/player/1'
      expect(response.status).to eq(200)
    end
  end
end
