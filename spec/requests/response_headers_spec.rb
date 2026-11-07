require 'rails_helper'

# 応答のヘッダー。ふつうのページはほかのサイトの枠に表示させず、ほかのサイトからも読ませない。
# 埋め込み用のものだけ、それぞれ必要なことを許す
describe 'Response headers' do
  let(:slide) { create(:slide) }
  let(:user) { slide.user }

  def cross_origin_allowed?
    response.headers['Access-Control-Allow-Origin'] == '*'
  end

  it 'sends the standard headers on ordinary pages and does not allow other sites' do
    get "/slides/#{slide.id}"
    expect(response.headers).to include(
      'X-Frame-Options' => 'SAMEORIGIN',
      'X-Content-Type-Options' => 'nosniff',
      'Referrer-Policy' => 'strict-origin-when-cross-origin',
    )
    expect(response.headers).not_to have_key('Access-Control-Allow-Origin')
  end

  it 'lets other sites show the HTML player in a frame' do
    get "/html_player/#{slide.id}"
    expect(response.status).to eq(200)
    expect(response.headers).not_to have_key('X-Frame-Options')
    expect(response.headers['X-Content-Type-Options']).to eq('nosniff')
  end

  it 'lets other sites read the API' do
    get "/api/v1/slides/#{slide.id}.json"
    expect(cross_origin_allowed?).to be(true)
    expect(response.headers['Access-Control-Allow-Methods']).to eq('GET')
  end

  it 'lets other sites read the API also when nothing is found' do
    get '/api/v1/slides/0.json'
    expect(response.status).to eq(404)
    expect(cross_origin_allowed?).to be(true)
  end

  it 'lets other sites read the player scripts' do
    get "/player/#{slide.id}"
    expect(cross_origin_allowed?).to be(true)
    get "/player/v2/#{slide.id}"
    expect(cross_origin_allowed?).to be(true)
  end

  it 'lets other sites read the embedded list of a user, but not the profile page' do
    get "/users/#{user.id}/embedded"
    expect(cross_origin_allowed?).to be(true)
    get "/users/#{user.id}"
    expect(response.headers).not_to have_key('Access-Control-Allow-Origin')
  end
end
