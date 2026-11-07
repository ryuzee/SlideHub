require 'rails_helper'

# スライド詳細ページの、JavaScript で動く部分をブラウザで確かめる
RSpec.describe 'Slide page in a browser', :js, type: :system do
  let(:slide) { create(:slide, name: 'Sushi Talk', num_of_pages: 3) }

  # プレイヤーのページ番号の表示（「1 / 3」）
  def page_position
    find('[id$="page_positions"]').text.gsub(/\s+/, ' ').strip
  end

  # プレイヤーの操作ボタン。アイコンは Font Awesome の JavaScript が SVG に差し替えるので、リンク先で探す
  def player_button(move)
    find(:xpath, "//a[contains(@href, '.moveTo(') and contains(@href, '#{move}')]")
  end

  def current_image
    find('[id$="slide_image"]', visible: :all)[:src]
  end

  before do
    # 文字起こしは、テスト用の画像バケットに置いてあることにする
    stub_request(:get, Transcript.new(slide.object_key).url).
      to_return(body: 'a:3:{i:0;s:10:"First page";i:1;s:11:"Second page";i:2;s:10:"Third page";}')
  end

  it 'shows the first page and moves with the buttons' do
    visit slide_path(slide)
    expect(page).to have_css('[id$="page_positions"]', text: '1 / 3')
    expect(current_image).to end_with("#{slide.object_key}/slide-1.jpg")

    player_button('currentPageIndex+1').click
    expect(page).to have_css('[id$="page_positions"]', text: '2 / 3')
    expect(current_image).to end_with("#{slide.object_key}/slide-2.jpg")

    player_button('slides.length-1').click
    expect(page).to have_css('[id$="page_positions"]', text: '3 / 3')

    player_button('moveTo(0)').click
    expect(page).to have_css('[id$="page_positions"]', text: '1 / 3')
  end

  it 'moves with the arrow keys' do
    visit slide_path(slide)
    expect(page).to have_css('[id$="page_positions"]', text: '1 / 3')
    find('body').send_keys(:right)
    expect(page).to have_css('[id$="page_positions"]', text: '2 / 3')
    find('body').send_keys(:left)
    expect(page).to have_css('[id$="page_positions"]', text: '1 / 3')
  end

  it 'opens the page from its number in the text' do
    visit slide_path(slide)
    expect(page).to have_css('.slide_description .item', count: 3)
    within(all('.slide_description .item')[2]) { click_link '3' }
    expect(page).to have_css('[id$="page_positions"]', text: '3 / 3')
    expect(page_position).to eq('3 / 3')
  end

  it 'opens the start position given in the URL' do
    visit "/slides/#{slide.id}/2"
    expect(page).to have_css('[id$="page_positions"]', text: '2 / 3')
  end

  it 'shows the code to embed the slide' do
    visit slide_path(slide)
    find('#show_embedded').click
    dialog = find('.embedded_dialog', visible: true)
    expect(dialog.find('#js', visible: true).text + dialog.all('textarea, input', visible: :all).map(&:value).join).
      to include("/player/v2/#{slide.id}")
  end
end
