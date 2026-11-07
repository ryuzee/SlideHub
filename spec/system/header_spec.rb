require 'rails_helper'

# ヘッダーの、JavaScript で開くメニューをブラウザで確かめる
RSpec.describe 'Header in a browser', :js, type: :system do
  it 'opens the menu with the toggle button on a phone-sized screen' do
    page.driver.browser.manage.window.resize_to(390, 844)
    visit latest_index_path
    expect(page).to have_no_css('#navbarSupportedContent.show')
    expect(page).to have_no_field('q[name_cont]')

    find('button.navbar-toggler').click
    expect(page).to have_css('#navbarSupportedContent.show')
    expect(page).to have_field('q[name_cont]')
  ensure
    page.driver.browser.manage.window.resize_to(1280, 900)
  end
end
