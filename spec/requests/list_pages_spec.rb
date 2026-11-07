require 'rails_helper'

# 公開画面の一覧。ページ番号が範囲外なら 404 にし、言語で出し分けていることを応答に示す
describe 'List pages' do
  let!(:slide) { create(:slide) }
  let(:user) { slide.user }
  let(:list_paths) do
    ['/latest', '/popular', "/categories/#{slide.category_id}", "/#{user.username}"]
  end

  it 'shows the first page and returns 404 for a page after the last one' do
    list_paths.each do |path|
      get path, params: { page: 1 }
      expect(response.status).to eq(200), path

      get path, params: { page: 2 }
      expect(response.status).to eq(404), path
    end
  end

  it 'shows the first page even when there is no slide' do
    get "/categories/#{create(:default_category, name_en: 'Empty', name_ja: 'Empty_ja').id}"
    expect(response.status).to eq(200)
  end

  it 'tells caches that the page depends on the browser language' do
    get '/latest', headers: { 'Accept-Language' => 'en' }
    expect(response.headers['Vary'].split(',').map(&:strip)).to include('Accept-Language', 'Accept')
  end
end
