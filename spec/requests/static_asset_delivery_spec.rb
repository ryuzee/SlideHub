require 'rails_helper'

# CSS・JavaScript などの圧縮とキャッシュ（config/initializers/static_asset_delivery.rb）
describe 'Delivery of pages and assets' do
  let(:gzip) { { 'Accept-Encoding' => 'gzip' } }

  it 'compresses pages and fingerprinted assets when the browser accepts it' do
    get '/latest', headers: gzip
    expect(response.headers['content-encoding']).to eq('gzip')

    get ActionController::Base.helpers.asset_path('application.css'), headers: gzip
    expect(response.status).to eq(200)
    expect(response.headers['content-encoding']).to eq('gzip')
  end

  it 'does not compress when the browser does not ask for it' do
    get '/latest'
    expect(response.headers['content-encoding']).to be_nil
  end

  it 'lets the browser keep fingerprinted assets for a year' do
    path = ActionController::Base.helpers.asset_path('application.css')
    expect(path).to match(/-[0-9a-f]{8,}\.css\z/)
    get path
    expect(response.headers['cache-control']).to eq('public, max-age=31536000, immutable')
  end

  it 'does not keep other files that long' do
    get '/iframeResizer.contentWindow.min.js'
    expect(response.status).to eq(200)
    expect(response.headers['cache-control']).not_to include('immutable')

    get '/latest'
    expect(response.headers['cache-control']).not_to include('immutable')
  end
end
