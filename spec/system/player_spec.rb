require 'rails_helper'

RSpec.describe 'Player', type: :system do
  it 'get /player/1' do
    slide = create(:slide)
    visit "/player/#{slide.id}"
    expect(page).to have_content('document.write')
  end

  it 'get /player/v2/1' do
    slide = create(:slide)
    visit "/player/v2/#{slide.id}"
    expect(page).to have_content('getElementById')
  end
end
