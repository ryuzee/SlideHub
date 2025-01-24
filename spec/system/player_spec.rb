require 'rails_helper'

RSpec.feature 'player' do
  scenario 'get /player/1' do
    slide = create(:slide)
    visit "/player/#{slide.id}"
    expect(page).to have_content('document.write')
  end

  scenario 'get /player/v2/1' do
    slide = create(:slide)
    visit "/player/v2/#{slide.id}"
    expect(page).to have_content('getElementById')
  end
end
