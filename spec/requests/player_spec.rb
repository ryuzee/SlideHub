require 'rails_helper'

describe 'Player' do
  describe 'GET /player/1' do
    it 'works!' do
      slide = create(:slide)
      allow_any_instance_of(SlidePages).to receive(:list).and_return(['/aaa/1.jpg'])
      allow_any_instance_of(Transcript).to receive(:lines).and_return([])
      get "/player/#{slide.id}"
      expect(response.status).to eq(200)
      expect(response.body).to include("getElementById")
    end
  end

  describe 'GET /player/v2/1' do
    it 'works!' do
      slide = create(:slide)
      allow_any_instance_of(SlidePages).to receive(:list).and_return(['/aaa/1.jpg'])
      allow_any_instance_of(Transcript).to receive(:lines).and_return([])
      get "/player/v2/#{slide.id}"
      expect(response.status).to eq(200)
      expect(response.body).to include("getElementById")
    end
  end
end
