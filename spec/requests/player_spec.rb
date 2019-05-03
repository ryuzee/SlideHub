require 'rails_helper'

describe 'Player' do
  describe 'GET /player/1' do
    it 'works!' do
      slide = create(:slide)
      allow_any_instance_of(SlidePages).to receive(:list).and_return(['/aaa/1.jpg'])
      allow_any_instance_of(Transcript).to receive(:lines).and_return([])
      get "/player/#{slide.id}"
      expect(response.status).to eq(200)
    end
  end
end
