require 'rails_helper'

# トップページの一覧は数分間キャッシュする。言語ごとに分けておかないと、
# 先に開いた人の言語の表示が、ほかの言語の人にも出てしまう
describe 'Top page cache' do
  around do |example|
    store = ActionController::Base.cache_store
    caching = ActionController::Base.perform_caching
    ActionController::Base.cache_store = ActiveSupport::Cache::MemoryStore.new
    ActionController::Base.perform_caching = true
    example.run
  ensure
    ActionController::Base.cache_store = store
    ActionController::Base.perform_caching = caching
  end

  before { create(:slide, name: 'Sushi Talk', total_view: 3) }

  def latest_list(language)
    get '/', headers: { 'Accept-Language' => language }
    expect(response.status).to eq(200)
    Nokogiri::HTML(response.body).at('#latest').text
  end

  it 'keeps the cached lists of each language apart' do
    expect(latest_list('en')).to include('3 views')
    expect(latest_list('ja')).to include('3 回閲覧')
    expect(latest_list('en')).to include('3 views')
  end
end
