require 'rails_helper'

describe 'PopularSlides' do
  let!(:slide) { create(:slide, name: 'Sushi Talk') }

  describe 'GET /popular' do
    it 'shows the published slides at both URLs' do
      %w[/popular /slides/popular].each do |path|
        get path
        expect(response.status).to eq(200)
        expect(response.body).to include('Sushi Talk')
      end
    end
  end

  describe 'GET /popular.rss' do
    it 'returns an RSS feed with the slides at both URLs' do
      %w[/popular.rss /slides/popular.rss].each do |path|
        get path
        expect(response.status).to eq(200)
        feed = Nokogiri::XML(response.body)
        expect(feed.at('rss')).not_to be_nil
        expect(feed.css('item title').map(&:text)).to include('Sushi Talk')
      end
    end
  end
end
